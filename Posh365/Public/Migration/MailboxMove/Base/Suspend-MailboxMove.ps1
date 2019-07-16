function Suspend-MailboxMove {
    <#
    .SYNOPSIS
    Suspend Mailbox Move

    .DESCRIPTION
    Suspend Mailbox Move

    .EXAMPLE
    Suspend-MailboxMove

    .NOTES
    Connect to Exchange Online
    #>
    [CmdletBinding()]
    param
    (
    )
    end {
        Invoke-SuspendMailboxMove | Out-Gridview -Title "Results of Suspend Mailbox Move"
    }
}
