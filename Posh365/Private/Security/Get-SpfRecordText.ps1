function Get-SpfRecordText {
    [CmdletBinding()]
    param (
        [Parameter()]
        $domainData
    )
    $record = $domainData.TXT | Where-Object { $_.Strings -like '*v=spf1*' } -ErrorAction SilentlyContinue

    if ($record -eq $null) { return }

    if (($record[0].Strings | Measure-Object).Count -gt 1) {
        $record[0].Strings -join ''
    }
    else {
        $record[0].Strings[0]
    }
}
