function Test-DnsHostingProvider {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainData
    )
    if ($DomainData.NS) {
        $nameServerRecords = ($DomainData.NS | Where-Object { $_.NameHost -ne $null } -ErrorAction SilentlyContinue | Select-Object -ExpandProperty NameHost -ErrorAction SilentlyContinue)

        if ($nameServerRecords) { $nameServerRecords -join ',' }
    }
}
