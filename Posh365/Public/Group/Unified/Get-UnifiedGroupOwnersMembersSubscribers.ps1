function Get-UnifiedGroupOwnersMembersSubscribers {
    param (

    )
    end {
        Get-UnifiedGroup -ResultSize Unlimited | Select-Object @(
            'DisplayName'
            @{
                Name       = 'EmailAddresses'
                Expression = { @($_.EmailAddresses) -ne '' -join '|' }
            }
            @{
                Name       = 'Members'
                Expression = { @((Get-UnifiedGroupLinks -Identity $_.Identity -LinkType Members).primarysmtpaddress) -ne '' -join '|' }
            }
            @{
                Name       = 'Subscribers'
                Expression = { @((Get-UnifiedGroupLinks -Identity $_.Identity -LinkType Subscribers).primarysmtpaddress) -ne '' -join '|' }
            }
            @{
                Name       = 'Owners'
                Expression = { @((Get-UnifiedGroupLinks -Identity $_.Identity -LinkType Owners).primarysmtpaddress) -ne '' -join '|' }
            }
            'ExchangeObjectId'
        )
    }
}
