function Invoke-GetCloudData {
    [CmdletBinding()]
    param (
        [Parameter()]
        $ResultSize = 'Unlimited',

        [Parameter()]
        [ValidateSet('Mailboxes', 'MailUsers', 'AzureADUsers')]
        $Type,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        $InitialDomain
    )
    $iUP = 0
    if ($Type -eq 'Mailboxes') {
        $MailboxList = Get-Mailbox -Filter "IsDirSynced -eq '$false'" -RecipientTypeDetails UserMailbox, SharedMailbox, RoomMailbox, EquipmentMailbox -ResultSize $ResultSize
        $Count = @($MailboxList).Count
        foreach ($Mailbox in $MailboxList) {
            $iUP++
            [PSCustomObject]@{
                Num                       = '[{0} of {1}]' -f $iUP, $Count
                DisplayName               = $Mailbox.DisplayName
                Name                      = $Mailbox.Name
                Type                      = 'Recipient'
                RecipientType             = $Mailbox.RecipientType
                RecipientTypeDetails      = $Mailbox.RecipientTypeDetails
                UserPrincipalName         = $Mailbox.UserPrincipalName
                ExternalEmailAddress      = $Mailbox.ExternalEmailAddress
                Alias                     = $Mailbox.Alias
                PrimarySmtpAddress        = $Mailbox.PrimarySmtpAddress
                ExchangeGuid              = $Mailbox.ExchangeGuid
                ArchiveGuid               = $Mailbox.ArchiveGuid
                LegacyExchangeDN          = $Mailbox.LegacyExchangeDN
                InitialAddress            = @($Mailbox.EmailAddresses -like "smtp:*@$InitialDomain")[0] -replace 'smtp:', ''
                EmailAddresses            = @($Mailbox.EmailAddresses) -notmatch "SPO:|SIP:" -join '|'
                ExternalDirectoryObjectId = $Mailbox.ExternalDirectoryObjectId
            }
        }
    }
    if ($Type -eq 'MailUsers') {
        $MailUserList = (Get-MailUser -Filter "IsDirSynced -eq '$false'" -ResultSize $ResultSize).where{ $_.UserPrincipalName -notlike "*#EXT#*" }
        foreach ($MailUser in $MailUserList) {
            $iUP++
            [PSCustomObject]@{
                Num                       = '[{0} of {1}]' -f $iUP, $Count
                DisplayName               = $Mailbox.DisplayName
                Name                      = $Mailbox.Name
                Type                      = 'Recipient'
                RecipientType             = $Mailbox.RecipientType
                RecipientTypeDetails      = $Mailbox.RecipientTypeDetails
                UserPrincipalName         = $Mailbox.UserPrincipalName
                ExternalEmailAddress      = $Mailbox.ExternalEmailAddress
                Alias                     = $Mailbox.Alias
                PrimarySmtpAddress        = $Mailbox.PrimarySmtpAddress
                ExchangeGuid              = $Mailbox.ExchangeGuid
                ArchiveGuid               = $Mailbox.ArchiveGuid
                LegacyExchangeDN          = $Mailbox.LegacyExchangeDN
                # VERIFY THIS
                InitialAddress            = if ($InitialAddress = ($Mailbox.EmailAddresses -like "smtp:*@$InitialDomain")[0] -replace 'smtp:', '') {
                    $InitialAddress
                }
                else { '{0}@{1}' -f ($Mailbox.UserPrincipalName -split '@')[0], $InitialDomain }
                EmailAddresses            = @($Mailbox.EmailAddresses) -notmatch "SPO:|SIP:" -join '|'
                ExternalDirectoryObjectId = $Mailbox.ExternalDirectoryObjectId
            }
        }
    }
    ############################################################
    # Need to handle existing AzureADUser from Source and Target
    # Build a hashSET of all recipients by GUID pull all AzureAD users -notin hashSET
    ############################################################
    if ($Type -eq 'AzureADUsers') {
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
}
