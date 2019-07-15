Function Remove-MailboxMove {
    <#
    .SYNOPSIS
    Remove Mailbox Move

    .DESCRIPTION
    Remove Mailbox Move

    .EXAMPLE
    Remove-MailboxMove

    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param
    (
    )
    Invoke-RemoveMailboxMove | Out-GridView -Title "Results of Remove Mailbox Move"
}
