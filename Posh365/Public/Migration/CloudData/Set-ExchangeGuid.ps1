using namespace System.Management.Automation.Host
function Set-ExchangeGuid {
    [CmdletBinding()]
    param (

        [Parameter()]
        [ValidateScript( { Test-Path $_ })]
        $SourceFilePath,

        [Parameter()]
        $AddGuidList

    )

    $ErrorActionPreference = 'Stop'
    if (-not $AddGuidList) {
        $AddGuidList = Import-Csv -Path $SourceFilePath
    }
    if ($AddGuidList) { Get-DecisionbyOGV } else { Write-Host 'Halting as nothing was selected' ; continue }

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
                Count              = '[{0} of {1}]' -f $iUP, $Count
                Displayname        = $AddGuid.DisplayName
                OrganizationalUnit = $AddGuid.OrganizationalUnit
                ExchangeGuidMatch  = $Stamped.ExchangeGuid -eq $AddGuid.ExchangeGuidCloud
                ArchiveGuidMatch   = $Stamped.ArchiveGuid -eq $AddGuid.ArchiveGuidCloud
                ExchangeGuidOnPrem = $Stamped.ExchangeGuid
                ExchangeGuidCloud  = $AddGuid.ExchangeGuidCloud
                ArchiveGuidOnPrem  = $Stamped.ArchiveGuid
                ArchiveGuidCloud   = $AddGuid.ArchiveGuidCloud
                UserPrincipalName  = $Stamped.UserPrincipalName
                Log                = 'SUCCESS'
            }
        }
        catch {
            Write-Host "[$iUP of $Count] Failed Set Guid $($AddGuid.DisplayName). Error: $($_.Exception.Message)" -ForegroundColor Red
            [PSCustomObject]@{
                Count              = '[{0} of {1}]' -f $iUP, $Count
                Displayname        = $AddGuid.DisplayName
                OrganizationalUnit = $AddGuid.OrganizationalUnit
                ExchangeGuidMatch  = 'FAILED'
                ArchiveGuidMatch   = 'FAILED'
                ExchangeGuidOnPrem = $Stamped.ExchangeGuid
                ExchangeGuidCloud  = $AddGuid.ExchangeGuidCloud
                ArchiveGuidOnPrem  = $Stamped.ExchangeGuidCloud
                ArchiveGuidCloud   = $AddGuid.ArchiveGuidCloud
                UserPrincipalName  = $Stamped.UserPrincipalName
                Log                = $_.Exception.Message
            }
        }
    }
    $ErrorActionPreference = 'Continue'
}