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
        $Count = @($MailUserList).Count
        foreach ($MailUser in $MailUserList) {
            $iUP++
            [PSCustomObject]@{
                Num                       = '[{0} of {1}]' -f $iUP, $Count
                DisplayName               = $MailUser.DisplayName
                Name                      = $MailUser.Name
                Type                      = 'Recipient'
                RecipientType             = $MailUser.RecipientType
                RecipientTypeDetails      = $MailUser.RecipientTypeDetails
                UserPrincipalName         = $MailUser.UserPrincipalName
                ExternalEmailAddress      = $MailUser.ExternalEmailAddress
                Alias                     = $MailUser.Alias
                PrimarySmtpAddress        = $MailUser.PrimarySmtpAddress
                ExchangeGuid              = $MailUser.ExchangeGuid
                ArchiveGuid               = $MailUser.ArchiveGuid
                LegacyExchangeDN          = $MailUser.LegacyExchangeDN
                # VERIFY THIS
                InitialAddress            = if ($InitialAddress = ($MailUser.EmailAddresses -like "smtp:*@$InitialDomain")[0] -replace 'smtp:', '') {
                    $InitialAddress
                }
                else { '{0}@{1}' -f ($MailUser.UserPrincipalName -split '@')[0], $InitialDomain }
                EmailAddresses            = @($MailUser.EmailAddresses) -notmatch "SPO:|SIP:" -join '|'
                ExternalDirectoryObjectId = $MailUser.ExternalDirectoryObjectId
            }
        }
    }
    ############################################################
    # Need to handle existing AzureADUser from Source and Target
    # Build a hashSET of all recipients by GUID pull all AzureAD users -notin hashSET
    ############################################################
    if ($Type -eq 'AzureADUsers') {
        $RecipientGuidSet = [System.Collections.Generic.HashSet[string]]::new()
        $RecipientList = Get-Recipient -ResultSize unlimited
        $RecipientList.ForEach( { $RecipientGuidSet.Add($_.ExternalDirectoryObjectId) })
        $AzureADUserList = Get-AzureADUser -All:$True | Where-Object { $_.DisplayName -ne 'On-Premises Directory Synchronization Service Account' -and -not $_.ImmutableId -and $_.UserPrincipalName -notlike "*#EXT#*" -and
            -not $_.ObjectId -notin $RecipientGuidSet
        }
        $Count = @($AzureADUserList).Count
        foreach ($AzureADUser in $AzureADUserList) {
            $iUP++
            [PSCustomObject]@{
                Num                       = '[{0} of {1}]' -f $iUP, $Count
                DisplayName               = $AzureADUser.DisplayName
                Name                      = ''
                Type                      = 'AzureADUser'
                RecipientType             = ''
                RecipientTypeDetails      = ''
                UserPrincipalName         = ''
                ExternalEmailAddress      = ''
                Alias                     = $AzureADUser.MailNickName
                PrimarySmtpAddress        = @(@($AzureADUser.ProxyAddresses ) -cmatch 'SMTP:') -ne '' -join '|'
                ExchangeGuid              = ''
                ArchiveGuid               = ''
                LegacyExchangeDN          = ''
                InitialAddress            = ($AzureADUser.ProxyAddresses -like "smtp:*@$InitialDomain")[0] -replace 'smtp:', ''
                EmailAddresses            = @(@($AzureADUser.ProxyAddresses) -notmatch "SPO:|SIP:") -ne '' -join '|'
                ExternalDirectoryObjectId = $AzureADUser.ObjectId
            }
        }
    }
}
