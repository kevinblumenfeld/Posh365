Function Get-LegacyDNHash {
    [CmdletBinding()]
    param (
        [Parameter()]
        $Mailbox,

        [Parameter()]
        $MailUser,

        [Parameter()]
        $MailContact,

        [Parameter()]
        $DistributionGroup
    )
    $LegDNHash = @{ }
    foreach ($Recipient in @($Mailbox ; $MailUser ; $MailContact ; $DistributionGroup)) {
        $LegDNHash[$Recipient.LegacyExchangeDN] = $Recipient.PrimarySMTPAddress
    }
    $LegDNHash
}
