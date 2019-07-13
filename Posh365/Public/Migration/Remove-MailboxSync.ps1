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
    Invoke-RemoveMailboxSync | Out-GridView -Title "Results of Remove Mailbox Sync"
}
