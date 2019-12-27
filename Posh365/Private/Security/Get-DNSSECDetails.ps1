function Get-DNSSECDetails {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainName
    )
    $ResolveSplat = @{
        Name          = $DomainName
        Type          = 'DNSKEY'
        ErrorAction   = 'SilentlyContinue'
        WarningAction = 'SilentlyContinue'
        Server        = '8.8.8.8'
    }
    $dnskey_dnsrecord = Resolve-DnsName @ResolveSplat | Where-Object { $_.Type -eq 'DNSKEY' }
    $dnskey_exists = (($dnskey_dnsrecord | Measure-Object | Select-Object -ExpandProperty Count) -gt 0)

    # If we don't detect an MTA-STS DNS record, return
    if ($dnskey_dnsrecord -eq $null) {
        Write-Verbose "Couldn't locate a DNSKEY record for domain: $DomainName"
        $dnskey_dnsrecord = "N/A"
    }

    [PSCustomObject]@{
        'DNSKeyExists' = $dnskey_exists
        'DNSKEYRecord' = $dnskey_dnsrecord
    }
}
