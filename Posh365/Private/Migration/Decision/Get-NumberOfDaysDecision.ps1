function Get-NumberOfDaysDecision {
    [CmdletBinding()]
    param (

    )
    end {
        $OGVDays = @{
            Title      = 'Migrate items with a date that is earlier than the specified number of days'
            OutputMode = 'Single '
        }
        ForEach-Object {
            for ($i = 30; $i -lt 181; $i = $i + 30) { $i }
        } | Sort-Object -Descending | Out-GridView @OGVDays
    }
}
