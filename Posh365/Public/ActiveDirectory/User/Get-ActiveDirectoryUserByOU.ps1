function Get-ActiveDirectoryUserByOU {
    <#
    .SYNOPSIS
    Export Active Directory Users by OU

    .DESCRIPTION
    Export Active Directory Users by OU

    .PARAMETER OrganizationalUnit
    Provide specific OUs to report on.

    .PARAMETER DetailedReport
    Provides a full report of all attributes.  Otherwise, only a refined report will be given.

    .EXAMPLE
    Get-ActiveDirectoryUserByOU | Export-Csv c:\scripts\ADUsers.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    Get-ActiveDirectoryUserByOU | Export-Csv c:\scripts\ADUsers.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    'OU=Contractors,OU=Corp,DC=contoso,DC=com','OU=Users,OU=Corp,DC=contoso,DC=com' | Get-ActiveDirectoryUserByOU  |  Export-Csv .\ADUsers.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    'OU=Users,OU=Corp,DC=contoso,DC=com' | Get-ActiveDirectoryUserByOU  -DetailedReport | Export-Csv .\ADUsers.csv -notypeinformation -encoding UTF8

    #>
    [CmdletBinding()]
    param (

        [Parameter(Position = 0, ParameterSetName = 'Standard')]
        $OrganizationalUnit,

        [Parameter()]
        [switch] $Recurse,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Pipeline')]
        [Alias('InputObject')]
        [string] $OUList,

        [Parameter()]
        [switch] $DetailedReport
    )
    Begin {
        $SearchScope = 'OneLevel'
        if ($Recurse) {
            $SearchScope = 'SubTree'
        }
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
                @{n = 'OU' ; e = { $_.DistinguishedName -replace '^.+?,(?=(OU|CN)=)' } },
                @{n = 'PrimarySmtpAddress' ; e = { [string]::join('|', [String[]]$_.ProxyAddresses -cmatch 'SMTP:') } },
                @{n = 'InheritanceBroken'; e = { $_.nTSecurityDescriptor.AreAccessRulesProtected } },
                @{n = 'altRecipientBL' ; e = { [string]::join('|', [String[]]$_.altRecipientBL -ne '') } },
                @{n = 'AuthenticationPolicy' ; e = { [string]::join('|', [String[]]$_.AuthenticationPolicy -ne '') } },
                @{n = 'AuthenticationPolicySilo' ; e = { [string]::join('|', [String[]]$_.AuthenticationPolicySilo -ne '') } },
                @{n = 'CompoundIdentitySupported' ; e = { [string]::join('|', [String[]]$_.CompoundIdentitySupported -ne '') } },
                @{n = 'dSCorePropagationData' ; e = { ($_.dSCorePropagationData | Where-Object { $_ -ne $null }) -join ';' } },
                @{n = 'KerberosEncryptionType' ; e = { [string]::join('|', [String[]]$_.KerberosEncryptionType -ne '') } },
                @{n = 'managedObjects' ; e = { [string]::join('|', [String[]]$_.managedObjects -ne '') } },
                @{n = 'MemberOf' ; e = { [string]::join('|', [String[]]$_.MemberOf -ne '') } },
                @{n = 'msExchADCGlobalNames' ; e = { [string]::join('|', [String[]]$_.msExchADCGlobalNames -ne '') } },
                @{n = 'msExchPoliciesExcluded' ; e = { [string]::join('|', [String[]]$_.msExchPoliciesExcluded -ne '') } },
                @{n = 'PrincipalsAllowedToDelegateToAccount' ; e = { [string]::join('|', [String[]]$_.PrincipalsAllowedToDelegateToAccount -ne '') } },
                @{n = 'protocolSettings' ; e = { [string]::join('|', [String[]]$_.protocolSettings -ne '') } },
                @{n = 'publicDelegatesBL' ; e = { [string]::join('|', [String[]]$_.publicDelegatesBL -ne '') } },
                @{n = 'securityProtocol' ; e = { [string]::join('|', [String[]]$_.securityProtocol -ne '') } },
                @{n = 'ServicePrincipalNames' ; e = { [string]::join('|', [String[]]$_.ServicePrincipalNames -ne '') } },
                @{n = 'showInAddressBook' ; e = { [string]::join('|', [String[]]$_.showInAddressBook -ne '') } },
                @{n = 'SIDHistory' ; e = { [string]::join('|', [String[]]$_.SIDHistory -ne '') } }
            )
            $ExtensionAttribute = @(
                'extensionAttribute1', 'extensionAttribute2', 'extensionAttribute3', 'extensionAttribute4', 'extensionAttribute5'
                'extensionAttribute6', 'extensionAttribute7', 'extensionAttribute8', 'extensionAttribute9', 'extensionAttribute10'
                'extensionAttribute11', 'extensionAttribute12', 'extensionAttribute13', 'extensionAttribute14', 'extensionAttribute15'
            )
        }
        else {
            $Props = @(
                'DisplayName', 'UserPrincipalName', 'mail', 'targetAddress', 'mailNickname'
                'GivenName', 'Surname', 'DistinguishedName', 'Enabled', 'proxyAddresses'
            )

            $QuickList = @(
                'DisplayName'
                'GivenName'
                'Surname'
                'UserPrincipalName'
                'mail'
                'mailNickname'
                'targetAddress'
                @{
                    n = 'PrimarySmtpAddress'
                    e = { [string]::join('|', [String[]]$_.ProxyAddresses -cmatch 'SMTP:') }
                }
                @{
                    n = 'proxyAddresses'
                    e = { [string]::join('|', [String[]]$_.ProxyAddresses -ne '') }
                }
                @{
                    n = 'OU'
                    e = { $_.DistinguishedName -replace '^.+?,(?=(OU|CN)=)' }
                }
                'objectGUID'
                'Enabled'
            )
        }
    }
    Process {
        switch ($PSCmdlet.ParameterSetName) {
            'Pipeline' {
                foreach ($OU in $OUList) {
                    if (-not $DetailedReport) {
                        $Clean = @{
                            SearchBase    = $OU
                            SearchScope   = $SearchScope
                            Properties    = $Props
                            Filter        = '*'
                            ResultSetSize = $null
                        }
                        Get-ADUser @Clean | Select-Object $QuickList
                    }
                    else {
                        $Detailed = @{
                            SearchBase    = $OU
                            SearchScope   = $SearchScope
                            Properties    = '*'
                            Filter        = '*'
                            ResultSetSize = $null
                        }
                        Get-ADUser @Detailed | Select-Object ($Selectproperties + $CalculatedProps + $ExtensionAttribute)
                    }
                }
            }
            'Standard' {
                foreach ($OU in $OrganizationalUnit) {
                    if (-not $DetailedReport) {
                        $Clean = @{
                            SearchBase    = $OU
                            SearchScope   = $SearchScope
                            Properties    = $Props
                            Filter        = '*'
                            ResultSetSize = $null
                        }
                        Get-ADUser @Clean | Select-Object $QuickList
                    }
                    else {
                        $Detailed = @{
                            SearchBase    = $OU
                            SearchScope   = $SearchScope
                            Properties    = '*'
                            Filter        = '*'
                            ResultSetSize = $null
                        }
                        Get-ADUser @Detailed | Select-Object ($Selectproperties + $CalculatedProps + $ExtensionAttribute)
                    }
                }
            }
        }
    }
    End {

    }
}