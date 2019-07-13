Function Suspend-MailboxMove {
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
    $UserChoice = Import-MailboxMoveDecision -NotCompleted
    if ($UserChoice -ne 'Quit' ) {
        foreach ($User in $UserChoice) {
            Suspend-MoveRequest -Identity $User.Guid -Confirm:$false
        }
    }
}
