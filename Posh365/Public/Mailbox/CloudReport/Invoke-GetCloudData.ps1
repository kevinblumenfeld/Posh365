function Invoke-GetCloudData {

    [CmdletBinding()]
    param (
        [Parameter()]
        $ResultSize = 'Unlimited',

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $InitialDomain
    )

    $MailboxList = Get-Mailbox -Filter "IsDirSynced -eq '$false'" -RecipientTypeDetails UserMailbox, SharedMailbox, RoomMailbox, EquipmentMailbox -ResultSize $ResultSize
    $MailboxList | Select-Object @(
        'DisplayName'
        @{
            Name       = 'Type'
            Expression = { 'Recipient' }
        }
        'RecipientType'
        'RecipientTypeDetails'
        'UserPrincipalName'
                'Alias'
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

    $MailUserList = (Get-MailUser -Filter "IsDirSynced -eq '$false'" -ResultSize $ResultSize).where{ $_.UserPrincipalName -notlike "*#EXT#*" }
    $MailUserList | Select-Object @(
        'DisplayName'
        @{
            Name       = 'Type'
            Expression = { 'Recipient' }
        }
        'RecipientType'
        'RecipientTypeDetails'
        'UserPrincipalName'
                'Alias'
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
    $MailandMEU = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($entry in @($MailUserList; $MailboxList)) {
        $null = $MailandMEU.Add($entry.UserPrincipalName)
    }

    Get-MsolUser -All | Where-Object {
        -not $_.ImmutableId -and $_.UserPrincipalName -notlike "*#EXT#*" -and -not $MailandMEU.Contains($_.UserPrincipalName)
    } | Select-Object @(
        'DisplayName'
        @{
            Name       = 'Type'
            Expression = { 'MsolUser' }
        }
        @{
            Name       = 'RecipientType'
            Expression = { '' }
        }
        @{
            Name       = 'RecipientTypeDetails'
            Expression = { '' }
        }
        'UserPrincipalName'
        @{
            Name       = 'Alias'
            Expression = { '' }
        }
        @{
            Name       = 'PrimarySmtpAddress'
            Expression = { (@($_.ProxyAddresses ) -cmatch 'SMTP:') -ne '' -join '|' }
        }
        @{
            Name       = 'ExchangeGuid'
            Expression = { '' }
        }
        @{
            Name       = 'ArchiveGuid'
            Expression = { '' }
        }
        @{
            Name       = 'LegacyExchangeDN'
            Expression = { '' }
        }
        @{
            Name       = 'InitialAddress'
            Expression = { ($_.ProxyAddresses -like "smtp:*@$InitialDomain")[0] -replace 'smtp:', '' }
        }
        @{
            Name       = 'EmailAddresses'
            Expression = { (@($_.ProxyAddresses) -notmatch "SPO:|SIP:") -ne '' -join '|' }
        }
        'ExternalEmailAddress'
    )
}
