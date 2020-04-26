function Set-msExchVersion {

    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $SkipConnection,

        [Parameter()]
        $OnPremExchangeServer,

        [Parameter()]
        [switch]
        $DeleteExchangeCreds,

        [Parameter()]
        [switch]
        $DontViewEntireForest
    )

    if (-not (Get-Module ActiveDirectory -ListAvailable)) {
        Write-Host 'Active Directory PowerShell Module not found.  Halting Script.' -ForegroundColor Red
        continue
    }
    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )
    if (-not (Test-Path $PoshPath)) {
        $null = New-Item $PoshPath -type Directory -Force:$true -ErrorAction SilentlyContinue
    }
    Import-Module ActiveDirectory -force
    Write-Host "`r`nCreating XML of all Active Directory Users with the following values in the attribute, msExchRecipientTypeDetails:" -ForegroundColor Green
    Write-Host "2147483648 (RemoteMailbox), 8589934592 (RemoteRoomMailbox), 17179869184 (RemoteEquipmentMailbox), 34359738368 (RemoteSharedMailbox)`r`n" -BackgroundColor White -ForegroundColor Black
    Write-Host "Breakdown of msExchVersion via Active Directory of Remote Mailbox types will be output shortly to Out Grid`r`n" -ForegroundColor Green
    $ADUserXML = Join-Path -Path $PoshPath -ChildPath 'RemoteMailbox_msExchVersion.xml'
    $ADParams = @{
        LDAPFilter    = '(|(msExchRecipientTypeDetails=8589934592)(msExchRecipientTypeDetails=2147483648)(msExchRecipientTypeDetails=17179869184)(msExchRecipientTypeDetails=34359738368))'
        Properties    = '*'
        ResultSetSize = $null
    }
    $UserList = Get-ADUser @ADParams
    $UserList | Export-Clixml $ADUserXML

    $UserHash = @{ }
    foreach ($User in $UserList) {
        $UserHash[$User.Guid.ToString()] = @{
            msExchVersion     = $User.msExchVersion
            DisplayName       = $User.DisplayName
            UserPrincipalName = $User.UserPrincipalName
        }
    }

    $VersionList = $UserList | Group-Object msExchVersion | Sort-Object Count -Descending
    $ShowVersion = [System.Collections.Generic.List[PSObject]]::New()
    foreach ($Version in $VersionList) {
        $ShowVersion.Add([PSCustomObject]@{
                'Count'   = $Version.Count
                'Version' = $Version.Name
            })
    }
    $ShowVersion | Out-GridView -Title 'Current breakdown of msExchVersion found in Remote Mailboxes'

    if (-not $SkipConnection) {
        Get-PSSession | Remove-PSSession
        Connect-Exchange @PSBoundParameters -PromptConfirm
    }

    $RemoteMailboxXML = Join-Path -Path $PoshPath -ChildPath 'RemoteMailbox_msExchVersion.xml'
    Write-Host 'Fetching Remote Mailboxes...' -ForegroundColor Cyan

    Get-RemoteMailbox -ResultSize Unlimited | Select-Object * | Export-Clixml $RemoteMailboxXML
    $RemoteMailboxList = Import-Clixml $RemoteMailboxXML | Sort-Object DisplayName, OnPremisesOrganizationalUnit

    Write-Host " Remote Mailboxes found in Active Directory (via msExchRecipientTypeDetails). Count:  $($UserList.Count)  " -ForegroundColor DarkBlue -BackgroundColor White
    Write-Host " Remote Mailboxes found in Exchange (via Get-RemoteMailbox). Count: $($RemoteMailboxList.Count)  " -ForegroundColor DarkBlue -BackgroundColor White
    Write-Host '  >> We will not modify any users in Active Directory unless a matching GUID is found in Exchange <<  ' -ForegroundColor DarkRed -BackgroundColor White

    $RMHash = @{ }
    foreach ($RM in $RemoteMailboxList) {
        $RMHash[$RM.Guid.ToString()] = @{
            DisplayName                  = $RM.DisplayName
            EmailAddressPolicyEnabled    = $RM.EmailAddressPolicyEnabled
            OnPremisesOrganizationalUnit = $RM.OnPremisesOrganizationalUnit
            Alias                        = $RM.Alias
            PrimarySmtpAddress           = $RM.PrimarySmtpAddress
            EmailCount                   = $RM.EmailAddresses.Count
            EmailAddresses               = @($RM.EmailAddresses) -match 'smtp:' -join '|'
            EmailAddressesNotSmtp        = @($RemoteMailbox.EmailAddresses) -notmatch 'smtp:' -join '|'
        }
    }

    Write-Host 'Choose which Remote Mailboxes to modify msExchVersion - Prior to modification, you will choose which version' -ForegroundColor Black -BackgroundColor White
    Write-Host 'To select use Ctrl/Shift + click (Individual) or Ctrl + A (All)' -ForegroundColor Black -BackgroundColor White

    $Choice = Select-SetmsExchVersion -RemoteMailboxList $RemoteMailboxList -UserHash $UserHash |
    Out-GridView -OutputMode Multiple -Title 'Choose which Remote Mailboxes to modify msExchVersion'
    $ChoiceCSV = Join-Path -Path $PoshPath -ChildPath ('Before modify msExchVersion {0}.csv' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))
    $Choice | Export-Csv $ChoiceCSV -NoTypeInformation -Encoding UTF8

    if ($Choice) { Get-DecisionbyOGV } else { Write-Host 'Halting as nothing was selected' ; continue }


    $VersionDecision = @(
        [PSCustomObject]@{
            Version       = 'Exchange2007'
            msExchVersion = '4535486012416'
        }
        [PSCustomObject]@{
            Version       = 'Exchange2010'
            msExchVersion = '44220983382016'
        }
        [PSCustomObject]@{
            Version       = 'Exchange2013'
            msExchVersion = '88218628259840'
        }
        [PSCustomObject]@{
            Version       = 'Exchange2016'
            msExchVersion = '1125899906842624'
        }) | Out-GridView -OutputMode Single -Title 'Choose the msExchVersion to apply the mailboxes you just selected'
    if ($Choice) { Get-DecisionbyOGV } else { Write-Host 'Halting as nothing was selected' ; continue }

    $Result = Invoke-SetmsExchVersion -Choice $Choice -Hash $RMHash -VersionDecision $VersionDecision.msExchVersion

    $Result | Out-GridView -Title ('Results of Disabling Email Address Policy  [ Count: {0} ]' -f $Result.Count)
    $ResultCSV = Join-Path -Path $PoshPath -ChildPath ('After modify msExchVersion {0}.csv' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))
    $Result | Export-Csv $ResultCSV -NoTypeInformation
}
