function Get-365MsolUser { 
    <#
    .SYNOPSIS
    Export Office 365 MsolUsers
    
    .DESCRIPTION
    Export Office 365 MsolUsers
    
    .PARAMETER SpecificMsolUsers
    Provide specific MsolUsers to report on.  Otherwise, all MsolUsers will be reported.  Please review the examples provided.
    
    .PARAMETER DetailedReport
    Provides a full report of all attributes.  Otherwise, only a refined report will be given.
    
    .EXAMPLE
    Get-365MsolUser | Export-Csv c:\scripts\All365MsolUsers.csv -notypeinformation -encoding UTF8
    
    .EXAMPLE
    Get-MsolUser -DomainName "contoso.com" -All | Select -ExpandProperty UserPrincipalName | Get-365MsolUser | Export-Csv c:\scripts\365MsolUsers.csv -notypeinformation -encoding UTF8
    
    .EXAMPLE
    Get-MsolUser -DomainName "contoso.com" -All | Select -ExpandProperty UserPrincipalName | Get-365MsolUser -DetailedReport | Export-Csv c:\scripts\365MsolUsers.csv -notypeinformation -encoding UTF8
    
    .EXAMPLE
    Get-Content "c:\scripts\UPNs.txt" | Get-365MsolUser | Export-Csv c:\scripts\365MsolUserExport.csv -notypeinformation -encoding UTF8
    
    Example of UPNs.txt
    #####################

    kevin@contoso.com
    sally@contoso.com
    larry@contoso.com

    #####################

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch] $DetailedReport,

        [Parameter(ValueFromPipeline = $true, Mandatory = $false)]
        [string[]] $SpecificUsers
    )
    Begin {
        if ($DetailedReport) {
            $Selectproperties = @('UserPrincipalName', 'DisplayName', 'Title', 'FirstName', 'LastName', 'StreetAddress', 'City', 'State', 'PostalCode', 'Country'
                'PhoneNumber', 'MobilePhone', 'Fax', 'Department', 'Office', 'PreferredDataLocation', 'PreferredLanguage', 'SignInName', 'LiveId'
                'UsageLocation', 'UserLandingPageIdentifierForO365Shell', 'ImmutableId', 'UserLandingPageIdentifierForO365Shell', 'BlockCredential'
                'IsLicensed', 'PasswordNeverExpires', 'PasswordResetNotRequiredDuringActivate', 'StrongPasswordRequired', 'LastDirSyncTime'
                'LastPasswordChangeTimestamp', 'SoftDeletionTimestamp', 'StsRefreshTokensValidFrom', 'WhenCreated', 'ObjectId', 'CloudExchangeRecipientDisplayType'
                'MSExchRecipientTypeDetails', 'StrongAuthenticationProofupTime', 'ReleaseTrack', 'UserType', 'ValidationStatus')

            $CalculatedProps = @(
                @{n = "AlternateEmailAddresses" ; e = {($_.AlternateEmailAddresses | ? {$_ -ne $null}) -join ";" }},
                @{n = "AlternateMobilePhones" ; e = {($_.AlternateMobilePhones | ? {$_ -ne $null}) -join ";" }},
                @{n = "AlternativeSecurityIds" ; e = {($_.AlternativeSecurityIds | ? {$_ -ne $null}) -join ";" }},
                @{n = "DirSyncProvisioningErrors" ; e = {($_.DirSyncProvisioningErrors | ? {$_ -ne $null}) -join ";" }},
                @{n = "Errors" ; e = {($_.Errors | ? {$_ -ne $null}) -join ";" }},
                @{n = "ExtensionData" ; e = {($_.ExtensionData | ? {$_ -ne $null}) -join ";" }},
                @{n = "IndirectLicenseErrors" ; e = {($_.IndirectLicenseErrors | ? {$_ -ne $null}) -join ";" }},
                @{n = "Licenses" ; e = {($_.Licenses | ? {$_ -ne $null}) -join ";" }},
                @{n = "OverallProvisioningStatus" ; e = {($_.OverallProvisioningStatus | ? {$_ -ne $null}) -join ";" }},
                @{n = "PortalSettings" ; e = {($_.PortalSettings | ? {$_ -ne $null}) -join ";" }},
                @{n = "ProxyAddresses" ; e = {($_.ProxyAddresses | ? {$_ -ne $null}) -join ";" }},
                @{n = "ServiceInformation" ; e = {($_.ServiceInformation | ? {$_ -ne $null}) -join ";" }},
                @{n = "StrongAuthenticationMethods" ; e = {($_.StrongAuthenticationMethods | ? {$_ -ne $null}) -join ";" }},
                @{n = "StrongAuthenticationPhoneAppDetails" ; e = {($_.StrongAuthenticationPhoneAppDetails | ? {$_ -ne $null}) -join ";" }},
                @{n = "StrongAuthenticationRequirements" ; e = {($_.StrongAuthenticationRequirements | ? {$_ -ne $null}) -join ";" }},
                @{n = "StrongAuthenticationUserDetails" ; e = {($_.StrongAuthenticationUserDetails | ? {$_ -ne $null}) -join ";" }}                              
            )
        }
        else {
            $Selectproperties = @('UserPrincipalName', 'DisplayName', 'Title', 'FirstName', 'LastName', 'StreetAddress', 'City', 'State', 'PostalCode', 'Country'
                'PhoneNumber', 'MobilePhone', 'Fax', 'Department', 'Office', 'PreferredDataLocation', 'PreferredLanguage', 'SignInName', 'LiveId'
                'UsageLocation', 'ImmutableId', 'LastDirSyncTime', 'IsLicensed', 'ObjectId')

            $CalculatedProps = @(
                @{n = "ProxyAddresses" ; e = {($_.ProxyAddresses | ? {$_ -ne $null}) -join ";" }}
            )
        }
    }
    Process {
        if ($SpecificUsers) {
            foreach ($CurUPN in $SpecificUsers) {
                Get-MsolUser -UserPrincipalName $CurUPN | Select-Object ($Selectproperties + $CalculatedProps)
            }
        }
        else {
            Get-MsolUser -All | Select-Object ($Selectproperties + $CalculatedProps)
        }
    }
    End {
        
    }
}