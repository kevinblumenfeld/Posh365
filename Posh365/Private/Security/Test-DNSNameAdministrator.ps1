function Test-DnsNameAdministrator {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainData
    )
    $DomainData.SOA | Select-Object -First 1 -ExpandProperty NameAdministrator -ErrorAction SilentlyContinue
}
