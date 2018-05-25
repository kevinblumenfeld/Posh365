Function Get-EXOMigrationStatistics {
    <#
    .SYNOPSIS
    Provides each user found in Get-MigrationUser in an Out-GridView.  The user can select one or more users for the report provided by Get-MigrationUserStatistics -Include report
    
    .DESCRIPTION
    Provides each user found in Get-MigrationUser in an Out-GridView.  The user can select one or more users for the report provided by Get-MigrationUserStatistics -Include report.
    Each report will open in a seperate Out-GridView
    
    .EXAMPLE
    Get-EXOMigrationStatistics

    #>
    [CmdletBinding()]
    param
    (

    )

    $currentErrorActionPrefs = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'

    $MigrationUser = Get-MigrationUser -ResultSize Unlimited
    $MigrationUserDetails = foreach ($User in $MigrationUser) {
        [PSCustomObject]@{
            Identity            = $User.Identity
            MailboxEmailAddress = $User.MailboxEmailAddress
            SkippedItemCount    = $User.SkippedItemCount
            SyncedItemCount     = $User.SyncedItemCount
            BatchId             = $User.BatchId
            RecipientType       = $User.RecipientType
            State               = $User.State
            Status              = $User.Status
            StatusSummary       = $User.StatusSummary
            TriggeredAction     = $User.TriggeredAction
            WorkflowStage       = $User.WorkflowStage
            WorkflowStep        = $User.WorkflowStep
            Guid                = $User.Guid
        }
    }
    $WantsDetailOnTheseMigrationUsers = $MigrationUserDetails | Out-GridView -PassThru -Title "Migration Users - Choose one or more and click OK for details"
    if ($WantsDetailOnTheseMigrationUsers) {
        Foreach ($Wants in $WantsDetailOnTheseMigrationUsers) {
            $UserStats = Get-MigrationUserStatistics -Identity $Wants.Guid -IncludeReport
            $UserStats.Report.Entries | Select-Object CreationTime, @{n = 'Migration User Statistics Report'; e = {$_.message}} | Sort-Object CreationTime -Descending |
                Out-GridView -Title "ID: $($Wants.Identity) EMAIL: $($Wants.MailboxEmailAddress) STATUS: $($Wants.Status) SYNCED: $($Wants.SyncedItemCount) SKIPPED: $($Wants.SkippedItemCount)" 
        }
    }
    else {
        Write-Verbose "`nNo Results found."
    }
    $ErrorActionPreference = $currentErrorActionPrefs
}