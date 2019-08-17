function Get-MWMailboxStat {
    [CmdletBinding()]
    Param
    (

    )
    end {
        foreach ($Mailbox in Get-MWMailbox) {
            Get-MW_MailboxStat -MailboxID $Mailbox.Id
        }
    }
}
