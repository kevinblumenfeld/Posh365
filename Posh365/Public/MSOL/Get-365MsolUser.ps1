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
                @{n = "AlternateEmailAddresses" ; e = {($_.AlternateEmailAddresses | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "AlternateMobilePhones" ; e = {($_.AlternateMobilePhones | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "AlternativeSecurityIds" ; e = {($_.AlternativeSecurityIds | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "DirSyncProvisioningErrors" ; e = {($_.DirSyncProvisioningErrors | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "Errors" ; e = {($_.Errors | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "ExtensionData" ; e = {($_.ExtensionData | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "IndirectLicenseErrors" ; e = {($_.IndirectLicenseErrors | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "Licenses" ; e = {($_.Licenses | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "OverallProvisioningStatus" ; e = {($_.OverallProvisioningStatus | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "PortalSettings" ; e = {($_.PortalSettings | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "proxyAddresses" ; e = {($_.proxyAddresses | Where-Object {$_ -ne $null}) -join '|' }},
                @{n = "ServiceInformation" ; e = {($_.ServiceInformation | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "StrongAuthenticationMethods" ; e = {($_.StrongAuthenticationMethods | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "StrongAuthenticationPhoneAppDetails" ; e = {($_.StrongAuthenticationPhoneAppDetails | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "StrongAuthenticationRequirements" ; e = {($_.StrongAuthenticationRequirements | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "StrongAuthenticationUserDetails" ; e = {($_.StrongAuthenticationUserDetails | Where-Object {$_ -ne $null}) -join ";" }}
            )
        }
        else {
            $Selectproperties = @(
                'UserPrincipalName', 'DisplayName', 'Title', 'FirstName', 'LastName', 'StreetAddress'
                'City', 'State', 'PostalCode', 'Country', 'PhoneNumber', 'MobilePhone', 'Fax', 'Department', 'Office'
                'LastDirSyncTime', 'IsLicensed'
            )

            $CalculatedProps = @(
                @{n = "proxyAddresses" ; e = {($_.proxyAddresses | Where-Object {$_ -ne $null}) -join '|' }}
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