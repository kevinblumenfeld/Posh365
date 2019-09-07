function Get-AzureActiveDirectoryUser {
    [CmdletBinding()]
    param (
    )
    end {
        Get-AzureADUser -All:$true | Select-Object @(
            'DisplayName'
            'UserPrincipalName'
            'Mail'
            'DirSyncEnabled'
            'AccountEnabled'
            @{
                Name       = 'OrganizationalUnit(CN)'
                Expression = { Convert-DistinguishedToCanonical -DistinguishedName ($_.extensionproperty.onPremisesDistinguishedName -replace '^.+?,(?=(OU|CN)=)') }
            }
            'UserType'
            'CreationType'
            'CompanyName'
            'Department'
            'JobTitle'
            'GivenName'
            'SurName'
            'StreetAddress'
            'City'
            'State'
            'PostalCode'
            'Country'
            'PhoneNumber'
            'Mobile'
            'TelephoneNumber'
            'Fax'
            'Office'
            'PreferredDataLocation'
            'PreferredLanguage'
            'SignInName'
            'LastDirSyncTime'
            'ObjectId'
            'ShowInAddressList'
            'UserState'
            'UserStateChangedOn'
            'MailNickName'
            'ImmutableId'
            'FacsimileTelephoneNumber'
            @{
                Name       = 'OrganizationalUnit'
                Expression = { $_.extensionproperty.onPremisesDistinguishedName -replace '^.+?,(?=(OU|CN)=)' }
            }
            @{
                Name       = 'DistinguishedName'
                Expression = { $_.extensionproperty.onPremisesDistinguishedName }
            }
            @{
                Name       = "OtherMails"
                Expression = { @($_.OtherMails) -ne '' -join '|' }
            }
            @{
                Name       = "proxyAddresses"
                Expression = { @($_.proxyAddresses) -ne '' -join '|' }
            }
        )
    }
}
