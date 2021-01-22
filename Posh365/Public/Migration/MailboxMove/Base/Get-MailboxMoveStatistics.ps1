Function Get-MailboxMoveStatistics {
    <#
    .SYNOPSIS
    Get Move Request Statistics and refresh by clicking OK

    .DESCRIPTION
    Get Move Request Statistics and refresh by clicking OK
    Uses Out-GridView to display and allows user to click OK to refresh

    .PARAMETER NotCompleted
    To only see the move requests that have yet to be completed

    .EXAMPLE
    Get-MailboxMoveStatistics

    .EXAMPLE
    Get-MailboxMoveStatistics -IncludeCompleted

    .NOTES
    Connect to Exchange Online prior to using
    #>

    [CmdletBinding()]
    [Alias('GMMS')]
    param
    (
        [Parameter()]
        [switch]
        $IncludeCompleted,

        [Parameter()]
        [Alias('PassThruData')]
        [switch]
        $RemoveAndRestart
    )

    Invoke-GetMailboxMoveStatisticsHelper -IncludeCompleted:$IncludeCompleted -RemoveAndRestart:$RemoveAndRestart
}
