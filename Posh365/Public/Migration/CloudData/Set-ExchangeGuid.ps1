using namespace System.Management.Automation.Host
function Set-ExchangeGuid {
    [CmdletBinding()]
    param (

        [Parameter()]
        [ValidateScript( { Test-Path $_ })]
        $SourceFilePath,

        [Parameter()]
        $AddGuidList,

        [Parameter(Mandatory)]
        $RMHash,

        [Parameter(Mandatory)]
        [string]
        $DomainController

    )

    $ErrorActionPreference = 'Stop'
    if (-not $AddGuidList) {
        $AddGuidList = Import-Csv -Path $SourceFilePath
    }
    if ($AddGuidList) { Get-DecisionbyOGV } else { Write-Host 'Halting script. No selected was made.' ; continue }

    $Count = @($AddGuidList).Count
    $iUP = 0
    foreach ($AddGuid in $AddGuidList) {
        $Stamped = $null
        $iUP++
        $SetParams = @{
            Identity         = $AddGuid.UserPrincipalName
            ErrorAction      = 'Stop'
            DomainController = $DomainController
        }
        if (-not $AddGuid.ExchangeGuidMatch) {
            $SetParams['ExchangeGuid'] = $AddGuid.ExchangeGuidCloud
        }
        if (-not $AddGuid.ArchiveGuidMatch) {
            $SetParams['ArchiveGuid'] = $AddGuid.ArchiveGuidCloud
        }
        try {
            Set-RemoteMailbox @SetParams
            $Stamped = Get-RemoteMailbox -Identity $AddGuid.UserPrincipalName -DomainController $DomainController
            Write-Host "[$iUP of $Count] Success Set Guid $($AddGuid.DisplayName) - All emails unchanged? " -ForegroundColor Green -NoNewline

            $AllAddressesUnchanged = $RMHash[$AddGuid.UserPrincipalName]['AllEmailAddresses'] -eq (@($Stamped.EmailAddresses) -ne '' -join '|')
            if ($AllAddressesUnchanged) {
                Write-Host $AllAddressesUnchanged -ForegroundColor White -BackgroundColor DarkMagenta
            }
            else {
                Write-Host $AllAddressesUnchanged -ForegroundColor Black -BackgroundColor Yellow
            }
            [PSCustomObject]@{
                Num                           = '[{0} of {1}]' -f $iUP, $Count
                Displayname                   = $AddGuid.DisplayName
                OrganizationalUnit            = $AddGuid.OrganizationalUnit
                PrimarySmtpAddressUnchanged   = $RMHash[$AddGuid.UserPrincipalName]['PrimarySmtpAddress'] -eq $Stamped.PrimarySmtpAddress
                AllAddressesUnchanged         = $AllAddressesUnchanged
                ExchangeGuidMatch             = $Stamped.ExchangeGuid -eq $AddGuid.ExchangeGuidCloud
                ArchiveGuidMatch              = $Stamped.ArchiveGuid -eq $AddGuid.ArchiveGuidCloud
                ExchangeGuidOnPrem            = $Stamped.ExchangeGuid
                ExchangeGuidCloud             = $AddGuid.ExchangeGuidCloud
                ArchiveGuidOnPrem             = $Stamped.ArchiveGuid
                ArchiveGuidCloud              = $AddGuid.ArchiveGuidCloud
                UserPrincipalName             = $Stamped.UserPrincipalName
                EmailCountChange              = $Stamped.EmailAddresses.Count - $RMHash[$AddGuid.UserPrincipalName]['EmailCount']
                CurrentEmailCount             = $Stamped.EmailAddresses.Count
                PreviousEmailCount            = $RMHash[$AddGuid.UserPrincipalName]['EmailCount']
                CurrentEmailAddresses         = @($Stamped.EmailAddresses) -match 'smtp:' -join '|'
                PreviousEmailAddresses        = $RMHash[$AddGuid.UserPrincipalName]['EmailAddresses']
                CurrentEmailAddressesNotSmtp  = @($Stamped.EmailAddresses) -notmatch 'smtp:' -join '|'
                PreviousEmailAddressesNotSmtp = $RMHash[$AddGuid.UserPrincipalName]['EmailAddressesNotSmtp']
                Guid                          = $Stamped.Guid.ToString()
                Log                           = 'SUCCESS'
            }
        }
        catch {
            Write-Host "[$iUP of $Count] Failed Set Guid $($AddGuid.DisplayName). Error: $($_.Exception.Message)" -ForegroundColor Red
            [PSCustomObject]@{
                Num                           = '[{0} of {1}]' -f $iUP, $Count
                Displayname                   = $AddGuid.DisplayName
                OrganizationalUnit            = $AddGuid.OrganizationalUnit
                PrimarySmtpAddressUnchanged   = 'FAILED'
                AllAddressesUnchanged         = 'FAILED'
                ExchangeGuidMatch             = 'FAILED'
                ArchiveGuidMatch              = 'FAILED'
                ExchangeGuidOnPrem            = $Stamped.ExchangeGuid
                ExchangeGuidCloud             = $AddGuid.ExchangeGuidCloud
                ArchiveGuidOnPrem             = $Stamped.ExchangeGuidCloud
                ArchiveGuidCloud              = $AddGuid.ArchiveGuidCloud
                UserPrincipalName             = $Stamped.UserPrincipalName
                EmailCountChange              = 'FAILED'
                CurrentEmailCount             = $Stamped.EmailAddresses.Count
                PreviousEmailCount            = 'FAILED'
                CurrentEmailAddresses         = @($Stamped.EmailAddresses) -match 'smtp:' -join '|'
                PreviousEmailAddresses        = 'FAILED'
                CurrentEmailAddressesNotSmtp  = @($Stamped.EmailAddresses) -notmatch 'smtp:' -join '|'
                PreviousEmailAddressesNotSmtp = 'FAILED'
                Guid                          = $Stamped.Guid.ToString()
                Log                           = $_.Exception.Message
            }
        }
    }
    $ErrorActionPreference = 'Continue'
}
