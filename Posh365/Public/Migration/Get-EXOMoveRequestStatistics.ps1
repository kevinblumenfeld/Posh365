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
            $MoveStats = Get-MoveRequestStatistics -Identity $Wants.Guid -IncludeReport
            $Size = [regex]::Matches("$($MoveStats.TotalMailboxSize)", "^[^(]*").value
            $MoveStats.Report.Entries | Select-Object CreationTime, @{n = 'Move Request Statistics Report'; e = { $_.message } } | Sort-Object CreationTime -Descending |
            Out-GridView -Title "$($Wants.DisplayName) $($MoveStats.PercentComplete)% $Size $($MoveStats.StatusDetail.value) $($MoveStats.Message)"
        }
    }
    else {
        Write-Verbose "`nNo Results found."
    }
    $ErrorActionPreference = $currentErrorActionPrefs
}
