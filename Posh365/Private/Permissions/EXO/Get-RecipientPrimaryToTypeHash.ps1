function Get-RecipientPrimaryToTypeHash {
    param (
        [Parameter(Mandatory)]
        $RecipientList
    )

    end {
        $RecipientMailToTypeHash = @{ }
        foreach ($Recipient in $RecipientList) {
            if ($Recipient.PrimarySMTPAddress) {
                $RecipientMailToTypeHash.Add($Recipient.PrimarySMTPAddress, $Recipient.RecipientTypeDetails)
            }
        }
        $RecipientMailToTypeHash
    }
}
