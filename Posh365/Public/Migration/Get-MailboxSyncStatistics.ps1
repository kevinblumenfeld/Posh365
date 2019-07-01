Function Get-MailboxSyncStatistics {
    <#
    .SYNOPSIS
    Get Move Request Statistics and refresh by clicking OK

    .DESCRIPTION
    Get Move Request Statistics and refresh by clicking OK
    Uses Out-GridView to display and allows user to click OK to refresh

    .PARAMETER NotCompleted
    To only see the move requests that have yet to be completed

    .EXAMPLE
    Get-MailboxSyncStatistics

    .EXAMPLE
    Get-MailboxSyncStatistics -NotCompleted

    .NOTES
    Connect to Exchange Online prior to using
    #>

    [CmdletBinding()]
    param
    (
        [Parameter()]
        [switch]
        $NotCompleted
    )

    if ($NotCompleted) {
        $NotCompletedSplat = @{
            Title      = "Move Requests Statistics - Not Completed. Click OK to Refresh"
            OutputMode = 'Multiple'
        }
        $RefreshNotCompleted = Import-MailboxSyncStatistics -NotCompleted | Out-GridView @NotCompletedSplat
    }
    else {
        $AllSplat = @{
            Title      = "Move Requests Statistics - All. Click OK to Refresh"
            OutputMode = 'Multiple'
        }
        $RefreshAll = Import-MailboxSyncStatistics | Out-GridView @AllSplat
    }
    if ($RefreshNotCompleted) {
        Get-MailboxSyncStatistics -NotCompleted
    }
    elseif ($RefreshAll) {
        Get-MailboxSyncStatistics
    }
}
