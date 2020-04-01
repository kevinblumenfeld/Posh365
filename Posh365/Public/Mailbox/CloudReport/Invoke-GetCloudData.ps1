function Invoke-GetCloudData {

    [CmdletBinding()]
    param (
        [Parameter()]
        $ResultSize = 'Unlimited',

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $InitialDomain
    )

    Get-Mailbox -Filter "IsDirSynced -eq '$false'" -ResultSize $ResultSize | Select-Object @(
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
            Expression = { ($_.EmailAddresses -like "smtp:*@$InitialDomain")[0] -replace 'smtp:', '' }
        }
        @{
            Name       = 'EmailAddresses'
            Expression = { @($_.EmailAddresses) -notmatch "SPO:|SIP:" -join '|' }
        }
        'ExternalEmailAddress'
    )
    (Get-MailUser -Filter "IsDirSynced -eq '$false'" -ResultSize $ResultSize).where{ $_.UserPrincipalName -notlike "*#EXT#*" } | Select-Object @(
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
            Expression = { ($_.EmailAddresses -like "smtp:*@$InitialDomain")[0] -replace 'smtp:', '' }
        }
        @{
            Name       = 'EmailAddresses'
            Expression = { @($_.EmailAddresses) -notmatch "SPO:|SIP:" -join '|' }
        }
        'ExternalEmailAddress'
    )
}
