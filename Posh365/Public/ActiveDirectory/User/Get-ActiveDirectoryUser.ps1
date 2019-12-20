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
    '{proxyaddresses -like "*contoso.com"}' | Get-ActiveDirectoryUser -DetailedReport | Export-Csv c:\scripts\ADUsers_Detailed.csv -notypeinformation -encoding UTF8

    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch] $DetailedReport,

        [Parameter(ValueFromPipeline = $true)]
        [string[]] $ADUserFilter
    )
    begin {
        if ($DetailedReport) {
            $Selectproperties = @(
                'DisplayName', 'UserPrincipalName', 'mail', 'CN', 'mailNickname', 'Name', 'GivenName', 'Surname', 'StreetAddress'
                'City', 'State', 'Country', 'PostalCode', 'Company', 'Title', 'Department', 'Description', 'OfficePhone'
                'MobilePhone', 'HomePhone', 'Fax', 'SamAccountName', 'DistinguishedName', 'Office', 'Enabled'
                'whenChanged', 'whenCreated', 'adminCount', 'AccountNotDelegated', 'AllowReversiblePasswordEncryption'
                'altRecipient', 'targetAddress', 'forwardingAddress', 'deliverAndRedirect', 'employeeType'
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
                @{n = "OU" ; e = { $_.DistinguishedName -replace '^.+?,(?=(OU|CN)=)' } },
                @{n = "PrimarySmtpAddress" ; e = { ( $_.proxyAddresses | Where-Object { $_ -cmatch "SMTP:" }) } },
                @{n = "proxyAddresses" ; e = { @($_.proxyAddresses) -ne '' -join '|' } },
                @{n = 'InheritanceBroken'; e = { $_.nTSecurityDescriptor.AreAccessRulesProtected } },
                @{n = "altRecipientBL" ; e = { @($_.altRecipientBL) -ne '' -join '|' } },
                @{n = "AuthenticationPolicy" ; e = { @($_.AuthenticationPolicy) -ne '' -join '|' } },
                @{n = "AuthenticationPolicySilo" ; e = { @($_.AuthenticationPolicySilo) -ne '' -join '|' } },
                @{n = "Certificates" ; e = { @($_.Certificates) -ne '' -join '|' } },
                @{n = "CompoundIdentitySupported" ; e = { @($_.CompoundIdentitySupported) -ne '' -join '|' } },
                @{n = "dSCorePropagationData" ; e = { @($_.dSCorePropagationData) -ne '' -join '|' } },
                @{n = "KerberosEncryptionType" ; e = { @($_.KerberosEncryptionType) -ne '' -join '|' } },
                @{n = "managedObjects" ; e = { @($_.managedObjects) -ne '' -join '|' } },
                @{n = "MemberOf" ; e = { @($_.MemberOf) -ne '' -join '|' } },
                @{n = "msExchADCGlobalNames" ; e = { @($_.msExchADCGlobalNames) -ne '' -join '|' } },
                @{n = "msExchPoliciesExcluded" ; e = { @($_.msExchPoliciesExcluded) -ne '' -join '|' } },
                @{n = "PrincipalsAllowedToDelegateToAccount" ; e = { @($_.PrincipalsAllowedToDelegateToAccount) -ne '' -join '|' } },
                @{n = "protocolSettings" ; e = { @($_.protocolSettings) -ne '' -join '|' } },
                @{n = "publicDelegatesBL" ; e = { @($_.publicDelegatesBL) -ne '' -join '|' } },
                @{n = "securityProtocol" ; e = { @($_.securityProtocol) -ne '' -join '|' } },
                @{n = "ServicePrincipalNames" ; e = { @($_.ServicePrincipalNames) -ne '' -join '|' } },
                @{n = "showInAddressBook" ; e = { @($_.showInAddressBook) -ne '' -join '|' } },
                @{n = "SIDHistory" ; e = { @($_.SIDHistory) -ne '' -join '|' } },
                @{n = "userCertificate" ; e = { @($_.userCertificate) -ne '' -join '|' } }
            )
            $ExtensionAttribute = @(
                'extensionAttribute1', 'extensionAttribute2', 'extensionAttribute3', 'extensionAttribute4', 'extensionAttribute5'
                'extensionAttribute6', 'extensionAttribute7', 'extensionAttribute8', 'extensionAttribute9', 'extensionAttribute10'
                'extensionAttribute11', 'extensionAttribute12', 'extensionAttribute13', 'extensionAttribute14', 'extensionAttribute15'
            )
        }
        else {
            $Props = @(
                'DisplayName', 'UserPrincipalName', 'mail', 'CN', 'mailNickname', 'Name', 'GivenName', 'Surname', 'StreetAddress',
                'City', 'State', 'Country', 'PostalCode', 'Company', 'Title', 'Department', 'Description', 'OfficePhone'
                'MobilePhone', 'HomePhone', 'Fax', 'SamAccountName', 'DistinguishedName', 'Office', 'Enabled'
                'whenChanged', 'whenCreated', 'adminCount', 'Memberof', 'msExchPoliciesExcluded', 'msExchRecipientTypeDetails', 'proxyAddresses'
            )
            $Selectproperties = @(
                'DisplayName', 'UserPrincipalName', 'mail', 'CN', 'mailNickname', 'Name', 'GivenName', 'Surname', 'StreetAddress',
                'City', 'State', 'Country', 'PostalCode', 'Company', 'Title', 'Department', 'Description', 'OfficePhone'
                'MobilePhone', 'HomePhone', 'Fax', 'SamAccountName', 'DistinguishedName', 'Office', 'Enabled'
                'whenChanged', 'whenCreated', 'adminCount', 'msExchRecipientTypeDetails', 'ObjectGUID'
            )

            $CalculatedProps = @(
                @{n = "PrimarySmtpAddress" ; e = { ( $_.proxyAddresses | Where-Object { $_ -cmatch "SMTP:" }) } },
                @{n = "proxyAddresses" ; e = { @($_.proxyAddresses) -ne '' -join '|' } },
                @{n = "OU" ; e = { $_.DistinguishedName -replace '^.+?,(?=(OU|CN)=)' } },
                @{n = "MemberOf" ; e = { @($_.MemberOf) -ne '' -join '|' } },
                @{n = "msExchPoliciesExcluded" ; e = { @($_.msExchPoliciesExcluded) -ne '' -join '|' } }
            )
        }
    }
    process {
        if ($ADUserFilter) {
            foreach ($CurADUserFilter in $ADUserFilter) {
                if (! $DetailedReport) {
                    Get-ADUser -Filter $CurADUserFilter -Properties $Props -ResultSetSize $null | Select-Object ($Selectproperties + $CalculatedProps)
                }
                else {
                    Get-ADUser -Filter $CurADUserFilter -Properties * -ResultSetSize $null | Select-Object ($Selectproperties + $CalculatedProps + $ExtensionAttribute)
                }
            }
        }
        else {
            if (! $DetailedReport) {
                Get-ADUser -Filter * -Properties $Props -ResultSetSize $null | Select-Object ($Selectproperties + $CalculatedProps)
            }
            else {
                Get-ADUser -Filter * -Properties * -ResultSetSize $null | Select-Object ($Selectproperties + $CalculatedProps + $ExtensionAttribute)
            }
        }
    }
    end {

    }
}
