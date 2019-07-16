Function Get-MailboxMoveRecipientHash {
    [CmdletBinding()]
    param
    (
    )
    end {
        $RecipientHash = @{ }
        $RecipientList = Get-Recipient -ResultSize Unlimited
        foreach ($Recipient in $RecipientList) {
            $RecipientHash[$Recipient.DistinguishedName] = @{
                PrimarySMTPAddress   = $Recipient.PrimarySMTPAddress
                RecipientTypeDetails = $Recipient.RecipientTypeDetails
            }
        }
        $RecipientHash
    }
}
