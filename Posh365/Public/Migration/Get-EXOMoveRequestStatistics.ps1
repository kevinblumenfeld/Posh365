Function Get-EXOMoveRequestStatistics {
    <#
    .SYNOPSIS
    Provides each user found in Get-MoveRequest in an Out-GridView.  The user can select one or more users for the report provided by Get-MoveRequestStatistics -Include report

    .DESCRIPTION
    Provides each user found in Get-MoveRequest in an Out-GridView.  The user can select one or more users for the report provided by Get-MoveRequestStatistics -Include report.
    Each report will open in a seperate Out-GridView

    .EXAMPLE
    Get-EXOMoveRequestStatistics

    #>
    [CmdletBinding()]
    param
    (

    )

    $currentErrorActionPrefs = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'

    $MoveRequest = Get-MoveRequest -ResultSize Unlimited
    $MoveRequestDetails = foreach ($Move in $MoveRequest) {
        [PSCustomObject]@{
            Identity                   = $Move.Identity
            Status                     = $Move.Status
            DisplayName                = $Move.DisplayName
            Alias                      = $Move.Alias
            BatchName                  = $Move.BatchName
            Suspend                    = $Move.Suspend
            SuspendWhenReadyToComplete = $Move.SuspendWhenReadyToComplete
            RecipientType              = $Move.RecipientType
            RecipientTypeDetails       = $Move.RecipientTypeDetails
            RemoteHostName             = $Move.RemoteHostName
            RequestStyle               = $Move.RequestStyle
            TargetDatabase             = $Move.TargetDatabase
            ExchangeGuid               = $Move.ExchangeGuid
            Guid                       = $Move.Guid
            Name                       = $Move.Name
        }
    }
    $WantsDetailOnTheseMoveRequests = $MoveRequestDetails | Out-GridView -PassThru -Title "Move Requests - Choose one or more and click OK for details"
    if ($WantsDetailOnTheseMoveRequests) {
        Foreach ($Wants in $WantsDetailOnTheseMoveRequests) {
            $Stats = Get-MoveRequestStatistics -Identity $Wants.Guid -IncludeReport
            $Size = [regex]::Matches("$($Stats.TotalMailboxSize)", "^[^(]*").value
            $FilterString = '{0} {1}% {2} {3} {4} of {5} {6}' -f $Wants.DisplayName, $Stats.PercentComplete, $Size, $Stats.StatusDetail.value, $Stats.ItemsTransferred, $Stats.TotalMailboxItemCount, $Stats.Message
            $Stats.Report.Entries | Select-Object CreationTime, @{n = 'Move Request Statistics Report'; e = { $_.message } } | Sort-Object CreationTime -Descending |
            Out-GridView -Title $FilterString
        }
    }
    else {
        Write-Verbose "`nNo Results found."
    }
    $ErrorActionPreference = $currentErrorActionPrefs
}
