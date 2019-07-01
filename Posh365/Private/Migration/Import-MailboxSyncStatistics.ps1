Function Import-MailboxSyncStatistics {
    <#

    #>
    [CmdletBinding()]
    param
    (

    )

    $MoveStat = Get-MoveRequest -ResultSize Unlimited | Get-MoveRequestStatistics
    foreach ($Stat in $MoveStat) {
        [PSCustomObject]@{
            Identity                   = $Stat.Identity
            Status                     = $Stat.Status
            BatchName                  = $Stat.BatchName
            DisplayName                = $Stat.DisplayName
            PercentComplete            = $Stat.PercentComplete
            BadItemLimit               = $Stat.BadItemLimit
            LargeItemLimit             = $Stat.LargeItemLimit
            TotalMailboxSize           = [regex]::Matches("$($Stat.TotalMailboxSize)", "^[^(]*").value
            ItemsTransferred           = $Stat.ItemsTransferred
            TotalMailboxItemCount      = $Stat.TotalMailboxItemCount
            StatusDetail               = $Stat.StatusDetail
            Suspend                    = $Stat.Suspend
            SuspendWhenReadyToComplete = $Stat.SuspendWhenReadyToComplete
            RecipientTypeDetails       = $Stat.RecipientTypeDetails
            RemoteHostName             = $Stat.RemoteHostName
            RequestStyle               = $Stat.RequestStyle
            TargetDatabase             = $Stat.TargetDatabase
            ExchangeGuid               = $Stat.ExchangeGuid
            Guid                       = $Stat.Guid
            Name                       = $Stat.Name
        }
    }
}
