using namespace System.Management.Automation.Host
function Set-ExchangeGuid {
    [CmdletBinding()]
    param (

        [Parameter()]
        [ValidateScript( { Test-Path $_ })]
        $SourceFilePath,

        [Parameter()]
        $AddGuidList,

        [Parameter()]
        $InitialDomain

    )

    $ErrorActionPreference = 'Stop'
    if (-not $AddGuidList) {
        $AddGuidList = Import-Csv -Path $SourceFilePath
    }

    $Yes = [ChoiceDescription]::new('&Yes', 'Set-RemoteDomain: Yes')
    $No = [ChoiceDescription]::new('&No', 'Set-RemoteDomain: No')
    $Question = "Are you ready to stamp Guids in this tenant: $InitialDomain ?"
    $Options = [ChoiceDescription[]]($Yes, $No)
    $Title = 'Please make a selection'
    $Menu = $host.ui.PromptForChoice($Title, $Question, $Options, 1)
    switch ($Menu) {
        0 {
            $Count = $AddGuidList.Count
            $iUP = 0
            foreach ($AddGuid in $AddGuidList) {
                $iUP++
                $SetParams = @{
                    Identity    = $AddGuid.UserPrincipalName
                    ErrorAction = 'Stop'
                }
                if (-not $AddGuid.ExchangeGuidMatch) {
                    $SetParams['ExchangeGuid'] = $AddGuid.ExchangeGuidCloud
                }
                if (-not $AddGuid.ArchiveGuidMatch) {
                    $SetParams['ArchiveGuid'] = $AddGuid.ArchiveGuidCloud
                }
                try {
                    Set-RemoteMailbox @SetParams
                    $Stamped = Get-RemoteMailbox -Identity $AddGuid.UserPrincipalName
                    Write-Host "[$iUP of $Count] Success Set Guid $($AddGuid.DisplayName)" -ForegroundColor Green
                    [PSCustomObject]@{
                        Displayname        = $AddGuid.DisplayName
                        OrganizationalUnit = $AddGuid.OrganizationalUnit
                        ExchangeGuidMatch  = $Stamped.ExchangeGuid -eq $AddGuid.ExchangeGuidCloud
                        ArchiveGuidMatch   = $Stamped.ArchiveGuid -eq $AddGuid.ArchiveGuidCloud
                        ExchangeGuidOnPrem = $Stamped.ExchangeGuid
                        ExchangeGuidCloud  = $AddGuid.ExchangeGuidCloud
                        ArchiveGuidOnPrem  = $Stamped.ArchiveGuid
                        ArchiveGuidCloud   = $AddGuid.ArchiveGuidCloud
                        UserPrincipalName =  $Stamped.UserPrincipalName
                    }
                }
                catch {
                    Write-Host "[$iUP of $Count] Failed Set Guid $($AddGuid.DisplayName)" -ForegroundColor Red
                    [PSCustomObject]@{
                        Displayname        = $AddGuid.DisplayName
                        OrganizationalUnit = $AddGuid.OrganizationalUnit
                        ExchangeGuidMatch  = 'FAILED'
                        ArchiveGuidMatch   = 'FAILED'
                        ExchangeGuidOnPrem = $Stamped.ExchangeGuid
                        ExchangeGuidCloud  = $AddGuid.ExchangeGuidCloud
                        ArchiveGuidOnPrem  = $Stamped.ExchangeGuidCloud
                        ArchiveGuidCloud   = $AddGuid.ArchiveGuidCloud
                        UserPrincipalName =  $Stamped.UserPrincipalName
                    }
                }
            }
        }
        1 { return }
    }
    $ErrorActionPreference = 'Continue'
}