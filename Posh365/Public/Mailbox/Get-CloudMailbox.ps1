function Get-CloudMailbox {
    [CmdletBinding()]
    param (

    )

    $InitialDomain = ((Get-AcceptedDomain).where{ $_.InitialDomain }).DomainName

    Get-Mailbox -Filter "IsDirSynced -eq '$false'" | Select-Object @(
        'DisplayName'
        'Alias'
        'RecipientType'
        'RecipientTypeDetails'
        'UserPrincipalName'
        'PrimarySmtpAddress'
        'ExchangeGuid'
        'ArchiveGuid'
        'LegacyExchangeDN'
        @{
            Name       = 'InitialAddress'
            Expression = { ($_.EmailAddresses -like "smtp:*@$InitialDomain")[0] }
        }
        @{
            Name       = 'EmailAddresses'
            Expression = { @($_.EmailAddresses) -ne '' -join '|' }
        }
        'ExternalEmailAddress'
    )

}
