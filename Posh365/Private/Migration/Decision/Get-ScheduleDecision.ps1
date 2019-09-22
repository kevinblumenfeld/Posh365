function Get-ScheduleDecision {
    [CmdletBinding()]
    param (

    )
    end {

        $OGVDate = @{
            Title      = 'Choose the date (your local time zone)'
            OutputMode = 'Single '
        }
        $OGVTime = @{
            Title      = 'Choose the time of day (your local time zone)'
            OutputMode = 'Single '
        }

        $DateChoice = 0..30 | ForEach-Object { [DateTime]::Now.Date.AddDays($_).ToString("M/d") } | Out-GridView @OGVDate
        $TimeChoice = 1..12 | ForEach-Object {
            for ($i = 0; $i -lt 60; $i = $i + 10) {
                '{0}:{1:d2}AM' -f $_, $i
                '{0}:{1:d2}PM' -f $_, $i
            }
        } | Sort-Object { [DateTime]$_ } | Out-GridView @OGVTime

        $TimeandDate = (([DateTime]$DateChoice) + ([DateTime]$TimeChoice).TimeOfDay).ToUniversalTime()
        $TimeandDate
    }
}
