function Get-RecipientCNHash {
    [CmdletBinding()]

    param ( )

    $RecipientHash = @{ }

    $RecipientList = Get-Recipient -ResultSize Unlimited

    foreach ($Recipient in $RecipientList) {

        $RecipientHash[$Recipient.Identity] = $Recipient.samAccountName
    }

    $RecipientHash

}
