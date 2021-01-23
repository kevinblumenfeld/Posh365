Function Get-MailboxMoveStatistics {
    <#
    .SYNOPSIS
    Get Move Request Statistics and refresh by clicking OK

    .DESCRIPTION
    Get Move Request Statistics and refresh by clicking OK
    Uses Out-GridView to display and allows user to click OK to refresh

    .PARAMETER IncludeCompleted
    To include completed move requests in the report
    Currently, completed move requests are always displayed with -ShowAllStats (To offer the choice, I will correct this on the next release)

    .EXAMPLE
    Get-MailboxMoveStatistics

    .EXAMPLE
    Get-MailboxMoveStatistics -IncludeCompleted

    .EXAMPLE
    Get-MailboxMoveStatistics -UploadToSharePointURL "https://contoso.sharepoint.com/sites/Migration" -ShowAllStats

    .NOTES
    Add a schedule task if you like:

        $Splat = @{
            TaskName        = "Hourly Migration Stats Task"
            User            = "user@domain.root"
            RepeatInMinutes = 60
            Executable      = "PowerShell.exe"
            Argument        = '-ExecutionPolicy RemoteSigned -Command "Connect-Cloud Contoso -EXO ; Get-MailboxMoveStatistics -UploadToSharePointURL "https://contoso.sharepoint.com/sites/Migration" -ShowAllStats"'
        }

        Add-TaskByMinute @Splat

    #>

    [CmdletBinding(DefaultParameterSetName = 'PlaceHolder')]
    [Alias('GMMS')]
    param
    (
        [Parameter()]
        [switch]
        $IncludeCompleted,

        [Parameter(ParameterSetName = 'RandR')]
        [Alias('PassThruData')]
        [switch]
        $RemoveAndRestart,

        [Parameter(ParameterSetName = 'SharePoint')]
        [string]
        $UploadToSharePointURL,

        [Parameter(ParameterSetName = 'SharePoint')]
        [switch]
        $ShowAllStats
    )
    if ($UploadToSharePointURL) {
        Invoke-GetMailboxMoveStatisticsHelper -IncludeCompleted:$true -UploadToSharePointURL $UploadToSharePointURL -ShowAllStats:$ShowAllStats
    }
    elseif ($RemoveAndRestart) {
        Invoke-GetMailboxMoveStatisticsHelper -IncludeCompleted:$IncludeCompleted -RemoveAndRestart:$RemoveAndRestart
    }
    else {
        Invoke-GetMailboxMoveStatisticsHelper -IncludeCompleted:$IncludeCompleted
    }
}
