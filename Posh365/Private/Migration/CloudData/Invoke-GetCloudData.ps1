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
        'Name'
        @{
            Name       = 'Type'
            Expression = { 'Recipient' }
        }
        'RecipientType'
        'RecipientTypeDetails'
        'UserPrincipalName'
        'ExternalEmailAddress'
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
        'ExternalDirectoryObjectId'
    )

    $MailUserList = (Get-MailUser -Filter "IsDirSynced -eq '$false'" -ResultSize $ResultSize).where{ $_.UserPrincipalName -notlike "*#EXT#*" }
    $MailUserList | Select-Object @(
        'DisplayName'
        'Name'
        @{
            Name       = 'Type'
            Expression = { 'Recipient' }
        }
        'RecipientType'
        'RecipientTypeDetails'
        'UserPrincipalName'
        'ExternalEmailAddress'
        'Alias'
        'PrimarySmtpAddress'
        'ExchangeGuid'
        'ArchiveGuid'
        'LegacyExchangeDN'
        @{
            Name       = 'InitialAddress'
            Expression = {
                if ($InitialAddress -eq ($_.EmailAddresses -like "smtp:*@$InitialDomain")[0] -replace 'smtp:', '') {
                    $InitialAddress
                }
                else {
                    '{0}@{1}' -f ($_.UserPrincipalName -split '@')[0], $InitialDomain
                }
            }
        }
        @{
            Name       = 'EmailAddresses'
            Expression = { @($_.EmailAddresses) -notmatch "SPO:|SIP:" -join '|' }
        }
        'ExternalDirectoryObjectId'
    )
    $MailandMEU = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($entry in @($MailUserList; $MailboxList)) {
        $null = $MailandMEU.Add($entry.UserPrincipalName)
    }

    Get-AzureADUser -All:$true | Where-Object { $_.DisplayName -ne 'On-Premises Directory Synchronization Service Account' -and
        -not $_.ImmutableId -and $_.UserPrincipalName -notlike "*#EXT#*" -and -not $MailandMEU.Contains($_.UserPrincipalName)
    } | Select-Object @(
        'DisplayName'
        @{
            Name       = 'Name'
            Expression = { '' }
        }
        @{
            Name       = 'Type'
            Expression = { 'AzureADUser' }
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
        'ExternalEmailAddress'
        @{
            Name       = 'Alias'
            Expression = { $_.MailNickName }
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
        @{
            Name       = 'ExternalDirectoryObjectId'
            Expression = { $_.ObjectId }
        }
    )
}
