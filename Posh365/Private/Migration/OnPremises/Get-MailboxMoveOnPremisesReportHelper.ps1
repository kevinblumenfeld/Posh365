Function Get-MailboxMoveOnPremisesReportHelper {
    [CmdletBinding()]
    param (

    )
    end {
        $RecHash = Get-MailboxMoveRecipientHash
        $MailboxList = Get-Mailbox -ResultSize Unlimited -IgnoreDefaultScope
        foreach ($Mailbox in $MailboxList) {
            Write-Verbose "Mailbox`t$($Mailbox.DisplayName)"
            $Statistic = $Mailbox | Get-ExchangeMailboxStatistics
            $PSHash = @{
                BatchName                  = ''
                DisplayName                = $Mailbox.DisplayName
                OrganizationalUnit         = $Mailbox.OrganizationalUnit
                IsMigrated                 = ''
                CompleteBatchDate          = ''
                CompleteBatchTimePT        = ''
                LicenseGroup               = ''
                EnableArchive              = ''
                ConvertToShared            = ''
                MailboxGB                  = $Statistic.MailboxGB
                ArchiveGB                  = $Statistic.ArchiveGB
                DeletedGB                  = $Statistic.DeletedGB
                TotalGB                    = $Statistic.TotalGB
                LastLogonTime              = $Statistic.LastLogonTime
                ItemCount                  = $Statistic.ItemCount
                UserPrincipalName          = $Mailbox.UserPrincipalName
                PrimarySmtpAddress         = $Mailbox.PrimarySmtpAddress
                AddressBookPolicy          = $Mailbox.AddressBookPolicy
                RetentionPolicy            = $Mailbox.RetentionPolicy
                AccountDisabled            = $Mailbox.UserAccountControl
                Alias                      = $Mailbox.Alias
                Database                   = $Mailbox.Database
                OU                         = ($Mailbox.DistinguishedName -replace '^.+?,(?=(OU|CN)=)')
                Office                     = $Mailbox.Office
                RecipientTypeDetails       = $Mailbox.RecipientTypeDetails
                UMEnabled                  = $Mailbox.UMEnabled
                ForwardingSmtpAddress      = $Mailbox.ForwardingSmtpAddress
                DeliverToMailboxAndForward = $Mailbox.DeliverToMailboxAndForward
            }
            if ($Mailbox.ForwardingAddress) {
                $Distinguished = Convert-CanonicalToDistinguished -CanonicalName $Mailbox.ForwardingAddress
                $PSHash.Add('ForwardingAddress', $RecHash[$Distinguished].PrimarySmtpAddress)
                $PSHash.Add('ForwardingRecipientType', $RecHash[$Distinguished].RecipientTypeDetails)
            }
            else {
                $PSHash.Add('ForwardingAddress', '')
                $PSHash.Add('ForwardingRecipientType', '')
            }
            New-Object -TypeName PSObject -Property $PSHash
        }
    }
}
