Function Remove-MailboxMove {
    <#
    .SYNOPSIS
    Remove Mailbox Sync

    .DESCRIPTION
    Remove Mailbox Sync
    .EXAMPLE
    Remove-MailboxMove

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param
    (

    )
    Invoke-RemoveMailboxMove | Out-GridView -Title "Results of Remove Mailbox Sync"
}
