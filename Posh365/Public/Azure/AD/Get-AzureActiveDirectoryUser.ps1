function Get-AzureActiveDirectoryUser {
    [CmdletBinding()]
    param (
    )
    end {
        $Selectproperties = @(
            'DisplayName', 'UserPrincipalName', 'Mail', 'DirSyncEnabled', 'AccountEnabled', 'UserType'
            'CreationType', 'CompanyName', 'Department', 'JobTitle', 'GivenName', 'SurName'
            'StreetAddress', 'City', 'State', 'PostalCode', 'Country', 'PhoneNumber', 'Mobile', 'TelephoneNumber', 'Fax'
            'Office', 'PreferredDataLocation', 'PreferredLanguage', 'SignInName', 'LastDirSyncTime'
            'ObjectId', 'ShowInAddressList', 'UserState', 'UserStateChangedOn', 'MailNickName', 'ImmutableId', 'FacsimileTelephoneNumber'
        )
        $CalculatedProps = @(
            @{n = 'OrganizationalUnit'; e = { $_.extensionproperty.onPremisesDistinguishedName -replace '^.+?,(?=(OU|CN)=)' } }
            @{n = 'DistinguishedName'; e = { $_.extensionproperty.onPremisesDistinguishedName } }
            @{n = "OtherMails" ; e = { @($_.OtherMails) -ne '' -join '|' } },
            @{n = "proxyAddresses" ; e = { @($_.proxyAddresses) -ne '' -join '|' } }
        )
        Get-AzureADUser -All:$true | Select-Object ($Selectproperties + $CalculatedProps)
    }
}
