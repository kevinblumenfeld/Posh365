Function Suspend-MailboxMove {
    <#
    .SYNOPSIS
    Suspend Mailbox Sync

    .DESCRIPTION
    Suspend Mailbox Sync
    .EXAMPLE
    Suspend-MailboxMove

    .NOTES
    General notes
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
