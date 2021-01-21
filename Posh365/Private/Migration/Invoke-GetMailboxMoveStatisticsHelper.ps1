Function Invoke-GetMailboxMoveStatisticsHelper {
    <#

    #>
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [switch]
        $IncludeCompleted,

        [Parameter()]
        [switch]
        $RemoveAndRestart
    )

    $MoveList = Invoke-GetMailboxMovePassThru -IncludeCompleted:$IncludeCompleted -RemoveAndRestart:$RemoveAndRestart
    if (-not $RemoveAndRestart) {
        $MoveList | Invoke-GetMailboxMoveStatistics | Out-GridView -Title "Statistics of mailbox moves"
    }
    else {
        $MoveList | Invoke-GetMailboxMoveStatistics
    }


}
