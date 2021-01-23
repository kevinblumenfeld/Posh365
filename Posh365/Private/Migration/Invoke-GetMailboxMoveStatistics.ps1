Function Invoke-GetMailboxMoveStatistics {
    <#

    #>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        $MoveList
    )
    process {
        foreach ($Move in $MoveList) {
            $StatList = $Move | Get-MoveRequestStatistics

            foreach ($Stat in $StatList) {
                [PSCustomObject]@{
                    Identity                   = $Stat.Identity
                    Status                     = $Stat.Status.toString()
                    BatchName                  = $Stat.BatchName
                    DisplayName                = $Stat.DisplayName
                    PercentComplete            = $Stat.PercentComplete
                    OverallDuration            = '{0:d2} days {1:d2}:{2:d2}' -f $Stat.OverallDuration.Days, $Stat.OverallDuration.Hours, $Stat.OverallDuration.Minutes
                    TotalFailedDuration        = '{0:d2} days {1:d2}:{2:d2}' -f $Stat.TotalFailedDuration.Days, $Stat.TotalFailedDuration.Hours, $Stat.TotalFailedDuration.Minutes
                    BadItemLimit               = $Stat.BadItemLimit
                    BadItemsEncountered        = $Stat.BadItemsEncountered
                    LargeItemLimit             = $Stat.LargeItemLimit
                    LargeItemsEncountered      = $Stat.LargeItemsEncountered
                    CompleteAfter              = $Stat.CompleteAfter
                    TotalMailboxSize           = [regex]::Matches("$($Stat.TotalMailboxSize)", "^[^(]*").value
                    ItemsTransferred           = $Stat.ItemsTransferred
                    TotalMailboxItemCount      = $Stat.TotalMailboxItemCount
                    StatusDetail               = $Stat.StatusDetail.toString()
                    DataConsistencyScore       = $Stat.DataConsistencyScore
                    Suspend                    = $Stat.Suspend
                    SuspendWhenReadyToComplete = $Stat.SuspendWhenReadyToComplete
                    RemoteDatabase             = $Stat.RemoteDatabase
                    RecipientTypeDetails       = $Stat.RecipientTypeDetails
                    RemoteHostName             = $Stat.RemoteHostName
                    RequestStyle               = $Stat.RequestStyle
                    TargetDatabase             = $Stat.TargetDatabase
                    ExchangeGuid               = $Stat.ExchangeGuid
                    Message                    = $Stat.Message
                }
            }
        }
    }
}
