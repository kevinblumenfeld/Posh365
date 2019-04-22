function Get-365MsolUser {
    <#
    .SYNOPSIS
    Export Office 365 MsolUsers

    .DESCRIPTION
    Export Office 365 MsolUsers

    .PARAMETER DomainFilter
    Specifies the domain to filter results on. This must be a verified domain for the company.
    All users with an email address, primary or secondary, on this domain is returned.

    .PARAMETER DetailedReport
    Provides a full report of all attributes.  Otherwise, only a refined report will be given.

    .EXAMPLE
    Get-365MsolUser | Export-Csv c:\scripts\All365MsolUsers.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    Get-365MsolUser -DetailedReport | Export-Csv c:\scripts\All365MsolUsers.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    'contoso.com','fabrikam.com' | Get-365MsolUser -DetailedReport| Export-Csv c:\scripts\365MsolUsers.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    'contoso.com','fabrikam.com' | Get-365MsolUser | Export-Csv c:\scripts\365MsolUsers.csv -notypeinformation -encoding UTF8

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch] $DetailedReport,

        [Parameter(ValueFromPipeline = $true, Mandatory = $false)]
        [string[]] $DomainFilter
    )
    Begin {
        if ($DetailedReport) {
            $Selectproperties = @(
                'UserPrincipalName', 'DisplayName', 'Title', 'FirstName', 'LastName', 'StreetAddress', 'City', 'State', 'PostalCode', 'Country'
                'PhoneNumber', 'MobilePhone', 'Fax', 'Department', 'Office', 'PreferredDataLocation', 'PreferredLanguage', 'SignInName', 'LiveId'
                'UsageLocation', 'UserLandingPageIdentifierForO365Shell', 'ImmutableId', 'BlockCredential', 'IsLicensed', 'PasswordNeverExpires'
                'PasswordResetNotRequiredDuringActivate', 'StrongPasswordRequired', 'LastDirSyncTime', 'LastPasswordChangeTimestamp'
                'SoftDeletionTimestamp', 'StsRefreshTokensValidFrom', 'WhenCreated', 'ObjectId', 'CloudExchangeRecipientDisplayType'
                'MSExchRecipientTypeDetails', 'StrongAuthenticationProofupTime', 'ReleaseTrack', 'UserType', 'ValidationStatus'
            )

            $CalculatedProps = @(
                @{n = "AlternateEmailAddresses" ; e = { [string]::join("|", [String[]]$_.AlternateEmailAddresses -ne '') } },
                @{n = "AlternateMobilePhones" ; e = { [string]::join("|", [String[]]$_.AlternateMobilePhones -ne '') } },
                @{n = "AlternativeSecurityIds" ; e = { [string]::join("|", [String[]]$_.AlternativeSecurityIds -ne '') } },
                @{n = "DirSyncProvisioningErrors" ; e = { [string]::join("|", [String[]]$_.DirSyncProvisioningErrors -ne '') } },
                @{n = "Errors" ; e = { [string]::join("|", [String[]]$_.Errors -ne '') } },
                @{n = "ExtensionData" ; e = { [string]::join("|", [String[]]$_.ExtensionData -ne '') } },
                @{n = "IndirectLicenseErrors" ; e = { [string]::join("|", [String[]]$_.IndirectLicenseErrors -ne '') } },
                @{n = "Licenses" ; e = { [string]::join("|", [String[]]$_.Licenses -ne '') } },
                @{n = "OverallProvisioningStatus" ; e = { [string]::join("|", [String[]]$_.OverallProvisioningStatus -ne '') } },
                @{n = "PortalSettings" ; e = { [string]::join("|", [String[]]$_.PortalSettings -ne '') } },
                @{n = "proxyAddresses" ; e = { [string]::join("|", [String[]]$_.proxyAddresses -ne '') } },
                @{n = "ServiceInformation" ; e = { [string]::join("|", [String[]]$_.ServiceInformation -ne '') } },
                @{n = "StrongAuthenticationMethods" ; e = { [string]::join("|", [String[]]$_.StrongAuthenticationMethods -ne '') } },
                @{n = "StrongAuthenticationPhoneAppDetails" ; e = { [string]::join("|", [String[]]$_.StrongAuthenticationPhoneAppDetails -ne '') } },
                @{n = "StrongAuthenticationRequirements" ; e = { [string]::join("|", [String[]]$_.StrongAuthenticationRequirements -ne '') } },
                @{n = "StrongAuthenticationUserDetails" ; e = { [string]::join("|", [String[]]$_.StrongAuthenticationUserDetails -ne '') } }

            )
        }
        else {
            $Selectproperties = @(
                'UserPrincipalName', 'DisplayName', 'Title', 'FirstName', 'LastName', 'StreetAddress'
                'City', 'State', 'PostalCode', 'Country', 'PhoneNumber', 'MobilePhone', 'Fax', 'Department', 'Office'
                'LastDirSyncTime', 'IsLicensed'
            )

            $CalculatedProps = @(
                @{n = "proxyAddresses" ; e = { [string]::join("|", [String[]]$_.proxyAddresses -ne '') } }
            )
        }
    }
    Process {
        if ($DomainFilter) {
            foreach ($CurDomainFilter in $DomainFilter) {
                Get-MsolUser -DomainName $CurDomainFilter -All | Select-Object ($Selectproperties + $CalculatedProps)
            }
        }
        else {
            Get-MsolUser -All | Select-Object ($Selectproperties + $CalculatedProps)
        }
    }
    End {

    }
}