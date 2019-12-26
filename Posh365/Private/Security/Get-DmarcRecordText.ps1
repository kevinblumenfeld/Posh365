function Get-DmarcRecordText {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainData
    )
    $record = $DomainData.DMARC | Where-Object { $_.Strings -like '*v=DMARC1*' } -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Strings -ErrorAction SilentlyContinue

    if ($record) {
        return $record
    }
    else {
        return "N/A"
    }
}
