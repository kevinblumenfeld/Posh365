function Test-DmarcRecordExists {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainData
    )
    $record = $DomainData.DMARC | Where-Object { $_.Strings -like '*v=DMARC1*' } -ErrorAction SilentlyContinue

    ($record -ne $null)
}
