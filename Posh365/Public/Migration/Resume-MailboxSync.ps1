Function Resume-MailboxSync {
    <#
    .SYNOPSIS
    Resume Mailbox Sync

    .DESCRIPTION
    Resume Mailbox Sync
    .EXAMPLE
    Resume-MailboxSync

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
            Resume-MoveRequest -Identity $User.Guid -Confirm:$false
        }
    }
}
