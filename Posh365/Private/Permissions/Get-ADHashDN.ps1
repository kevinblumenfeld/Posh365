Function Get-ADHashDN {
    param (
        [parameter(ValueFromPipeline = $true)]
        $MailboxList
    )
    begin {
        $ADHashDN = @{ }
    }
    process {
        foreach ($Mailbox in $MailboxList) {
            $ADHashDN[$Mailbox.DistinguishedName] = @{
                DisplayName        = $Mailbox.DisplayName
                UserPrincipalName  = $Mailbox.UserPrincipalName
                Logon              = $Mailbox.logon
                PrimarySMTPAddress = $Mailbox.PrimarySMTPAddress
            }
        }
    }
    end {
        $ADHashDN
    }
}
