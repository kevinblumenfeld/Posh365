function Get-MTASTSDetails {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainName
    )
    $ResolveSplat = @{
        Name          = "_mta-sts.$DomainName"
        Type          = 'TXT'
        ErrorAction   = 'SilentlyContinue'
        WarningAction = 'SilentlyContinue'
        Server        = '8.8.8.8'
    }
    $mtasts_dnsrecord = Resolve-DnsName @ResolveSplat
    $mtasts_policy = $null

    # If we don't detect an MTA-STS DNS record, return
    if ($mtasts_dnsrecord -eq $null) { return }

    # Try and retrieve the MTA-STS policy for the domain
    try {
        $uri = "https://mta-sts.$DomainName/.well-known/mta-sts.txt"

        $mtasts_policy = Invoke-WebRequest -Uri $uri -ErrorAction Stop | Select-Object -ExpandProperty Content

    }
    catch {
        Write-Verbose "Couldn't retrieve MTA-STS policy for domain: $DomainName"
    }

    # If we retrieved an MTA-STS policy, extract details from the plain-text file
    # into an object
    if ($mtasts_policy -ne $null) {

        [PSCustomObject]@{
            'DNSRecord' = $mtasts_dnsrecord
            'Version'   = "$(($mtasts_policy | Select-String -Pattern "version:(.*)").Matches.Groups[1])" -replace ' ' # only STSv1 is valid, so this property isn't used elsewhere in the script yet
            'Mode'      = ($mtasts_policy | Select-String -Pattern "mode:.*(enforce|testing|none)").Matches[0].Captures[0].Groups[1].Value.ToUpper()
            'AllowedMX' = (($mtasts_policy | Select-String -Pattern 'mx:(.*)' -AllMatches).Matches.Groups | Where-Object { $_.Value -notlike "mx:*" } | Select-Object -ExpandProperty value) -replace " " -join ','
        }
    }
}
