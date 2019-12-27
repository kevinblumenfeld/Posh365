function Get-O365FederationHostname {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainData
    )
    if ((Test-O365IsFederated $DomainData) -eq $false) {
        return 'N/A'
    }
    else {
        # Determine the auth URL hostname component. Not as elegant as a regex, but it works
        $authUrlHost = $DomainData.FEDERATION.AuthURL
        $authUrlHost = $authUrlHost.Replace('https://', '') # Remove HTTPS:// from the URL
        $authUrlHost = $authUrlHost.Replace('http://', '') # Remove HTTP:// from the URL, almost 0% chance of this ever existing
        $authUrlHost = $authUrlHost.Split('/')[0] # Split the auth URL, and grab the first component, the hostname

        return $authUrlHost
    }
}
