function Get-ActiveDirectoryUser { 
    <#
    .SYNOPSIS
    Export Active Directory Users
    
    .DESCRIPTION
    Export Active Directory Users
    
    .PARAMETER ADUserFilter
    Provide specific AD Users to report on.  Otherwise, all AD Users will be reported.  Please review the examples provided.
    
    .PARAMETER DetailedReport
    Provides a full report of all attributes.  Otherwise, only a refined report will be given.
    
    .EXAMPLE
    Get-ActiveDirectoryUser | Export-Csv c:\scripts\ADUsers.csv -notypeinformation -encoding UTF8
    
    .EXAMPLE
    Get-ActiveDirectoryUser | Export-Csv c:\scripts\ADUsers.csv -notypeinformation -encoding UTF8
    
    .EXAMPLE
    '{proxyaddresses -like "*contoso.com"}' | Get-ActiveDirectoryUser | Export-Csv c:\scripts\ADUsers.csv -notypeinformation -encoding UTF8
    
    .EXAMPLE
    '{proxyaddresses -like "*contoso.com"}' | Get-ActiveDirectoryUser -ArchivesOnly | Export-Csv c:\scripts\ADUsers.csv -notypeinformation -encoding UTF8
    
    .EXAMPLE
    '{proxyaddresses -like "*contoso.com"}' | Get-ActiveDirectoryUser -DetailedReport | Export-Csv c:\scripts\ADUsers_Detailed.csv -notypeinformation -encoding UTF8
    
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch] $DetailedReport,

        [Parameter(ValueFromPipeline = $true, Mandatory = $false)]
        [string[]] $ADUserFilter
    )
    Begin {
        if ($DetailedReport) {
            $Selectproperties = @(
                'DisplayName', 'UserPrincipalName', 'mail', 'CN', 'mailNickname', 'Name', 'GivenName', 'Surname', 'StreetAddress'
                'City', 'State', 'Country', 'PostalCode', 'Company', 'Title', 'Department', 'Description', 'OfficePhone'
                'MobilePhone', 'HomePhone', 'Fax', 'SamAccountName', 'DistinguishedName', 'Office', 'Enabled'
                'whenChanged', 'whenCreated', 'adminCount', 'AccountNotDelegated', 'AllowReversiblePasswordEncryption'
                'CannotChangePassword', 'Deleted', 'DoesNotRequirePreAuth', 'HomedirRequired', 'isDeleted', 'LockedOut'
                'mAPIRecipient', 'mDBUseDefaults', 'MNSLogonAccount', 'msExchHideFromAddressLists'
                'msNPAllowDialin', 'PasswordExpired', 'PasswordNeverExpires', 'PasswordNotRequired', 'ProtectedFromAccidentalDeletion'
                'SmartcardLogonRequired', 'TrustedForDelegation', 'TrustedToAuthForDelegation', 'UseDESKeyOnly', 'logonHours'
                'msExchMailboxGuid', 'replicationSignature', 'AccountExpirationDate', 'AccountLockoutTime', 'Created', 'createTimeStamp'
                'LastBadPasswordAttempt', 'LastLogonDate', 'Modified', 'modifyTimeStamp', 'msTSExpireDate', 'PasswordLastSet'
                'msExchMailboxSecurityDescriptor', 'nTSecurityDescriptor', 'BadLogonCount', 'codePage', 'countryCode'
                'deletedItemFlags', 'dLMemDefault', 'garbageCollPeriod', 'instanceType', 'msDS-SupportedEncryptionTypes'
                'msDS-User-Account-Control-Computed', 'msExchALObjectVersion', 'msExchMobileMailboxFlags', 'msExchRecipientDisplayType'
                'msExchUserAccountControl', 'primaryGroupID', 'replicatedObjectVersion', 'sAMAccountType', 'sDRightsEffective'
                'userAccountControl', 'accountExpires', 'lastLogonTimestamp', 'lockoutTime', 'msExchRecipientTypeDetails', 'msExchVersion'
                'pwdLastSet', 'uSNChanged', 'uSNCreated', 'ObjectGUID', 'objectSid', 'SID', 'autoReplyMessage', 'CanonicalName'
                'displayNamePrintable', 'Division', 'EmployeeID', 'EmployeeNumber', 'HomeDirectory', 'HomeDrive', 'homeMDB', 'homeMTA'
                'HomePage', 'Initials', 'LastKnownParent', 'legacyExchangeDN', 'LogonWorkstations'
                'Manager', 'msExchHomeServerName', 'msExchUserCulture', 'msTSLicenseVersion', 'msTSManagingLS'
                'ObjectCategory', 'ObjectClass', 'Organization', 'OtherName', 'POBox', 'PrimaryGroup'
                'ProfilePath', 'ScriptPath', 'sn', 'textEncodedORAddress', 'userParameters'
            )

            $CalculatedProps = @(
                @{n = "OU" ; e = {$_.DistinguishedName -replace '^.+?,(?=(OU|CN)=)'}},
                @{n = "proxyAddresses" ; e = {($_.proxyAddresses | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "altRecipientBL" ; e = {($_.altRecipientBL | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "AuthenticationPolicy" ; e = {($_.AuthenticationPolicy | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "AuthenticationPolicySilo" ; e = {($_.AuthenticationPolicySilo | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "Certificates" ; e = {($_.Certificates | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "CompoundIdentitySupported" ; e = {($_.CompoundIdentitySupported | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "dSCorePropagationData" ; e = {($_.dSCorePropagationData | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "KerberosEncryptionType" ; e = {($_.KerberosEncryptionType | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "managedObjects" ; e = {($_.managedObjects | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "MemberOf" ; e = {($_.MemberOf | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "msExchADCGlobalNames" ; e = {($_.msExchADCGlobalNames | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "msExchPoliciesExcluded" ; e = {($_.msExchPoliciesExcluded | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "PrincipalsAllowedToDelegateToAccount" ; e = {($_.PrincipalsAllowedToDelegateToAccount | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "protocolSettings" ; e = {($_.protocolSettings | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "publicDelegatesBL" ; e = {($_.publicDelegatesBL | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "securityProtocol" ; e = {($_.securityProtocol | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "ServicePrincipalNames" ; e = {($_.ServicePrincipalNames | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "showInAddressBook" ; e = {($_.showInAddressBook | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "SIDHistory" ; e = {($_.SIDHistory | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "userCertificate" ; e = {($_.userCertificate | Where-Object {$_ -ne $null}) -join ";" }}
            )
        }
        else {
            $Props = @(
                'DisplayName', 'UserPrincipalName', 'mail', 'CN', 'mailNickname', 'Name', 'GivenName', 'Surname', 'StreetAddress',
                'City', 'State', 'Country', 'PostalCode', 'Company', 'Title', 'Department', 'Description', 'OfficePhone'
                'MobilePhone', 'HomePhone', 'Fax', 'SamAccountName', 'DistinguishedName', 'Office', 'Enabled'
                'whenChanged', 'whenCreated', 'adminCount', 'Memberof', 'msExchPoliciesExcluded', 'proxyAddresses'
            )
            $Selectproperties = @(
                'DisplayName', 'UserPrincipalName', 'mail', 'CN', 'mailNickname', 'Name', 'GivenName', 'Surname', 'StreetAddress',
                'City', 'State', 'Country', 'PostalCode', 'Company', 'Title', 'Department', 'Description', 'OfficePhone'
                'MobilePhone', 'HomePhone', 'Fax', 'SamAccountName', 'DistinguishedName', 'Office', 'Enabled'
                'whenChanged', 'whenCreated', 'adminCount'
            )
            
            $CalculatedProps = @(
                @{n = "proxyAddresses" ; e = {($_.proxyAddresses | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "OU" ; e = {$_.DistinguishedName -replace '^.+?,(?=(OU|CN)=)'}},
                @{n = "MemberOf" ; e = {($_.MemberOf | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "msExchPoliciesExcluded" ; e = {($_.msExchPoliciesExcluded | Where-Object {$_ -ne $null}) -join ";" }}
            )
        }
    }
    Process {
        if ($ADUserFilter) {
            foreach ($CurADUserFilter in $ADUserFilter) {
                if (! $DetailedReport) {
                    Get-ADUser -Archive -Filter $CurADUserFilter -Properties $Props -ResultSetSize $null | Select-Object ($Selectproperties + $CalculatedProps)
                }
                else {
                    Get-ADUser -Archive -Filter $CurADUserFilter -Properties * -ResultSetSize $null | Select-Object ($Selectproperties + $CalculatedProps)
                }
            }
        }
        else {
            if (! $DetailedReport) {
                Get-ADUser -Filter * -Properties $Props -ResultSetSize $null | Select-Object ($Selectproperties + $CalculatedProps)
            }
            else {
                Get-ADUser -Filter * -Properties * -ResultSetSize $null | Select-Object ($Selectproperties + $CalculatedProps)
            }
        }
    }
    End {
        
    }
}