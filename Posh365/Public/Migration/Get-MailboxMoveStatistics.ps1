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
    param
    (
        [Parameter()]
        [switch]
        $IncludeCompleted
    )

    if ($IncludeCompleted) {
        $AllSplat = @{
            Title      = "Move Requests Statistics - All. Click OK to Refresh"
            OutputMode = 'Multiple'
        }
        $RefreshAll = Invoke-GetMailboxMoveStatistics | Out-GridView @AllSplat
    }
    else {
        $NotCompletedSplat = @{
            Title      = "Move Requests Statistics - Not Completed. Click OK to Refresh"
            OutputMode = 'Multiple'
        }
        $RefreshNotCompleted = Invoke-GetMailboxMoveStatistics -NotCompleted | Out-GridView @NotCompletedSplat
    }
    if ($RefreshNotCompleted) {
        Get-MailboxMoveStatistics
    }
    elseif ($RefreshAll) {
        Get-MailboxMoveStatistics -IncludeCompleted
    }
}
