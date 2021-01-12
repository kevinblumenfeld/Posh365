Function Get-MailboxMoveReportDataHelper {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Wants
    )

    $Stats = Get-MoveRequestStatistics -Identity $Wants.Guid -IncludeReport
    $Size = [regex]::Matches("$($Stats.TotalMailboxSize)", "^[^(]*").value
    foreach ($Log in $Stats.Report.Entries) {
        [PSCustomObject]@{
            DisplayName       = $Wants.DisplayName
            CreationTime     = $Log.CreationTime.toLocalTime()
            Log              = $Log.Message
            PercentComplete  = $Stats.PercentComplete
            MailboxSize      = $Size
            Detail           = $Stats.StatusDetail.value
            ItemsTransferred = $Stats.ItemsTransferred
            ItemCount        = $Stats.TotalMailboxItemCount
            Message          = $Stats.Message
        }
    }
}
