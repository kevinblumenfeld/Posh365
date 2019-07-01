Function Suspend-MailboxSync {
    <#
    .SYNOPSIS
    Suspend Mailbox Sync

    .DESCRIPTION
    Suspend Mailbox Sync
    .EXAMPLE
    Suspend-MailboxSync

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param
    (

    )

    $UserChoice = Import-MailboxSyncDecision -NotCompleted
    if ($UserChoice -ne 'Quit' ) {
        foreach ($User in $UserChoice) {
            Suspend-MoveRequest -Identity $User.Guid -Confirm:$false
        }
    }
}
