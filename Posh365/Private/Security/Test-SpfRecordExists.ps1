function Test-SpfRecordExists {
    [CmdletBinding()]
    param (
        [Parameter()]
        $domainData
    )
    $record = $domainData.TXT | Where-Object { $_.Strings -like '*v=spf1*' } -ErrorAction SilentlyContinue

    if (($record | Measure-Object).Count -gt 1) {
        return "ERROR: MULTIPLE SPF RECORDS"
    }
    else {
        ($record -ne $null)
    }
}
