Function Test-MailboxMoveUPNMatch {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $MailboxList
    )
    end {
        foreach ($Mailbox in $MailboxList) {
            if (($PrimarySmtp = (Get-MailUser $Mailbox.UserPrincipalName).PrimarySmtpAddress) -ne $Mailbox.UserPrincipalName) {
                [PSCustomObject]@{
                    UserPrincipalName  = $Mailbox.UserPrincipalName
                    PrimarySmtpAddress = $PrimarySmtp
                }

            }
        }
    }
}
