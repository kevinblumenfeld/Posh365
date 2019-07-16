Function Invoke-GetMailboxMoveStatisticsHelper {
    <#

    #>
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [switch]
        $IncludeCompleted
    )
    end {
        if ($IncludeCompleted) {
            $MoveList = Invoke-GetMailboxMovePassThru -IncludeCompleted
            $MoveList | Invoke-GetMailboxMoveStatistics | Out-GridView -Title "Statistics of mailbox moves"
        }
        else {
            $MoveList = Invoke-GetMailboxMovePassThru
            $MoveList | Invoke-GetMailboxMoveStatistics | Out-GridView -Title "Statistics of mailbox moves"
        }
    }
}
