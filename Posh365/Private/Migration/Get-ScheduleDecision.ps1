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

        $DateChoice = 0..14 | ForEach-Object { [DateTime]::Now.Date.AddDays($_).ToString("M/d") } | Out-GridView @OGVDate
        $TimeChoice = 1..12 | ForEach-Object { "${_}AM", "${_}PM" } | Sort-Object { [DateTime]$_ } | Out-GridView @OGVTime

        $TimeandDate = (([DateTime]$DateChoice) + ([DateTime]$TimeChoice).TimeOfDay).ToUniversalTime()
        $TimeandDate
    }
}
