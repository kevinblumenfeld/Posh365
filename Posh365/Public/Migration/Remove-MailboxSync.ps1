Function Remove-MailboxSync {
    <#
    .SYNOPSIS
    Remove Mailbox Sync

    .DESCRIPTION
    Remove Mailbox Sync
    .EXAMPLE
    Remove-MailboxSync

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param
    (

    )

    $UserChoice = Import-MailboxSyncDecision
    if ($UserChoice -ne 'Quit' ) {
        foreach ($User in $UserChoice) {
            [PSCustomObject]@{
                DisplayName = $User.DisplayName
                Action      = "REMOVE"
            }
            Remove-MoveRequest -Identity $User.Guid -Confirm:$false
        }
    }
}
