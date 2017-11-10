Function Sync-ADConnect {
    Param (
        [Parameter(Mandatory = $False)]    
        [switch] $Initial,
        [Parameter(Mandatory = $False)]
        [string]$Sleep = "60"
    )
    <#
    .SYNOPSIS
    Forces Sync of Azure AD Connect (Synchronizes on premises Active Directory with Azure AD/Office 366)

    .EXAMPLE
    # Delta Sync - This should be used unless there are extenuating circumstances

    Sync-ADConnect

    # Initial Sync
    # Typically used if an OU is added or removed from list of OUs to be synced
    # Can also be used when a normal Delta sync is not syncing a particular change
    
    Sync-ADConnect -Initial

    # Use the -Sleep switch to add a longer delay to sync if AD Connect is already in the midst of syncing
    # This only comes into play if the initial sync errors out...
    # ...at that point, the script will wait the number of seconds you specify and attempt sync again
    
    Sync-ADConnect -Sleep 240

    Sync-ADConnect -Initial -Sleep 240

    #>
    $RootPath = $env:USERPROFILE + "\ps\"
    $User = $env:USERNAME
    
    while (!(Test-Path ($RootPath + "$($user).ADConnectServer"))) {
        Select-ADConnectServer
    }
    $aadComputer = Get-Content ($RootPath + "$($user).ADConnectServer")

    if ($initial) {
        Start-Job -Name ADConnectSync -ScriptBlock {
            $aadcomputer = $args[0]
            Start-Sleep -Seconds 10
            $session = New-PSSession -ComputerName $aadComputer
            Invoke-Command -Session $session -ScriptBlock {
                Import-Module -Name 'ADSync'
                Try {
                    Start-ADSyncSyncCycle -PolicyType Initial -erroraction Stop
                }
                Catch {
                    Start-Sleep -Seconds $Sleep
                    Start-ADSyncSyncCycle -PolicyType Initial
                }
            }
            Remove-PSSession $session
        } -ArgumentList $aadComputer | Out-Null
    }
    else {

        Start-Job -Name ADConnectSync -ScriptBlock {
            $aadcomputer = $args[0]
            Start-Sleep -Seconds 10
            $session = New-PSSession -ComputerName $aadComputer
            Invoke-Command -Session $session -ScriptBlock {
                Import-Module -Name 'ADSync'
                Try {
                    Start-ADSyncSyncCycle -PolicyType Delta -erroraction Stop
                }
                Catch {
                    Start-Sleep -Seconds $Sleep
                    Start-ADSyncSyncCycle -PolicyType Delta
                }
            }
            Remove-PSSession $session
        } -ArgumentList $aadComputer | Out-Null
    }
}

