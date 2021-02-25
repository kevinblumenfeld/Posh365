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
    (    )

    $UserChoice = Get-MailboxMoveStatistics -PassThruData | Out-GridView -PassThru -Title 'Choose Mailbox Move(s) to Suspend'
    if ($UserChoice) {
        Invoke-SuspendMailboxMove -UserChoice $UserChoice | Out-GridView -Title "Results of Suspend Mailbox Move"
    }
}
