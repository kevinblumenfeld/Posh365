function Test-O365FederationProvider {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainData
    )
    # https://docs.microsoft.com/en-au/power-platform/admin/powerapps-gdpr-dsr-guide-systemlogs#determining-tenant-type

    # Check if we have any federation data for this domain
    if ($DomainData.FEDERATION -eq $null) { return }

    # Only federated domains return the AuthURL property
    if ($DomainData.FEDERATION.AuthURL -eq $null) { return "N/A" }

    Write-Verbose "Domain $($DomainData.SOA.Name) federation auth URL: $($DomainData.FEDERATION.AuthURL)"

    # Determine the auth URL hostname component. Not as elegant as a regex, but it works
    $authUrlHost = $DomainData.FEDERATION.AuthURL
    $authUrlHost = $authUrlHost.Replace('https://', '') # Remove HTTPS:// from the URL
    $authUrlHost = $authUrlHost.Replace('http://', '') # Remove HTTP:// from the URL, almmost 0% chance of this ever existing
    $authUrlHost = $authUrlHost.Split('/')[0] # Split the auth URL, and grab the first component, the hostname

    # Check URL hostnames and return a determination if they match
    switch -Wildcard ($authUrlHost) {
        '*.okta.com' { $determination = "Okta" }
        "*$($DomainData.SOA.Name)" { $determination = "Self-Hosted" }

        $null { $determination = "N/A" }
        Default { $determination = "Other/Undetermined" }
    }

    return $determination
}
