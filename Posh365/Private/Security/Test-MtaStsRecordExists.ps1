function Test-MtaStsRecordExists {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainData
    )
    $mtaRecord = $DomainData.MTASTS | Where-Object { $_.Strings -like "v=STSv1*" } -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Strings -ErrorAction SilentlyContinue

    ($mtaRecord -ne $null)
}
