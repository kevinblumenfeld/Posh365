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
        $RemoveAndRestart,

        [Parameter()]
        [string]
        $UploadToSharePointURL
    )

    $MoveList = Invoke-GetMailboxMovePassThru -IncludeCompleted:$IncludeCompleted -RemoveAndRestart:$RemoveAndRestart
    if ($UploadToSharePointURL) {
        $TempExcel = Join-Path -Path $Env:Temp -ChildPath ('{0}.xlsx' -f [guid]::newguid().guid)
        $StatSplat = @{
            Path                    = $TempExcel
            TableStyle              = 'Medium2'
            FreezeTopRowFirstColumn = $true
            AutoSize                = $true
            BoldTopRow              = $false
            ClearSheet              = $true
            ErrorAction             = 'SilentlyContinue'
            WorksheetName           = 'MoveStats'
            ConditionalText         = @(
                New-ConditionalText -ConditionalType ContainsText 'Completed' -ConditionalTextColor White -BackgroundColor ([System.Drawing.Color]::FromArgb(64, 64, 64)) -Range "B:B"
                New-ConditionalText -ConditionalType ContainsText 'AutoSuspended' -ConditionalTextColor Black -BackgroundColor ([System.Drawing.Color]::FromArgb(226, 239, 226)) -Range "B:B"
                New-ConditionalText -ConditionalType ContainsText 'InProgress' -ConditionalTextColor Black -BackgroundColor ([System.Drawing.Color]::FromArgb(250, 215, 253))  -Range "B:B"
                New-ConditionalText -ConditionalType ContainsText 'Failed' -ConditionalTextColor Black -BackgroundColor ([System.Drawing.Color]::FromArgb(252, 228, 214))  -Range "B:B"
            )
        }
        Write-Host "Retrieving statistics. . . " -ForegroundColor Green
        $MoveList | Invoke-GetMailboxMoveStatistics | Select-Object @(
            'BatchName'
            'Status'
            @{
                Name       = 'Percent'
                Expression = { $_.PercentComplete }
            }
            'DisplayName'
            'OverallDuration'
            'TotalFailedDuration'
            @{
                Name       = 'Size'
                Expression = { $_.TotalMailboxSize }
            }
            'StatusDetail'
            'Message'
        ) | Sort-Object -Property BatchName, DisplayName | Export-Excel @StatSplat
        Write-Host "Report created. . . " -ForegroundColor White
        Write-Host "Uploading to $UploadToSharePointURL . . . " -ForegroundColor Green
        try {
            $StatsFile = ('Stats {0}.xlsx' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))
            $StatsFilePath = Join-Path -Path $Env:Temp -ChildPath $StatsFile
            Rename-Item -Path $TempExcel -NewName $StatsFilePath
            $null = Add-PoshPnPFile -SharePointUrl $UploadToSharePointURL -FilePath $StatsFilePath
            Write-Host "Upload of the file " -ForegroundColor White -NoNewline
            Write-Host "$StatsFile " -ForegroundColor Cyan -NoNewline
            Write-Host "is complete." -ForegroundColor White
        }
        finally {
            Remove-Item -Path $StatsFilePath -Force -Confirm:$false -ErrorAction SilentlyContinue
        }
        return
    }
    if (-not $RemoveAndRestart) {
        $MoveList | Invoke-GetMailboxMoveStatistics | Out-GridView -Title "Statistics of mailbox moves"
    }
    else {
        $MoveList | Invoke-GetMailboxMoveStatistics
    }


}
