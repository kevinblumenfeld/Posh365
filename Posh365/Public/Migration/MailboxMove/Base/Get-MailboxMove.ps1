Function Get-MailboxMove {
    <#
    .SYNOPSIS
    Get Mailbox Moves

    .DESCRIPTION
    Get Mailbox Moves

    .PARAMETER IncludeCompleted
    Use this switch to view All mailbox moves that are not yet complete

    .EXAMPLE
    Get-MailboxMove

    .EXAMPLE
    Get-MailboxMove -IncludeCompleted

    .NOTES
    Connect to Exchange Online first.
    Connect-CloudMFA -Tenant Contoso -ExchangeOnline
    #>
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [switch]
        $IncludeCompleted
    )

    if ($IncludeCompleted) {
        Invoke-GetMailboxMove | Out-GridView -Title "All mailbox moves"
    }
    else {
        Invoke-GetMailboxMove -NotCompleted | Out-GridView -Title "All mailbox moves that are not yet complete"
    }
}
