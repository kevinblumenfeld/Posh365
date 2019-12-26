function Test-O365DirectoryID {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainName
    )
    try {
        $uri = "https://login.windows.net/$DomainName/.well-known/openid-configuration"

        $openIDResponse = Invoke-RestMethod -Uri $uri -ErrorAction Stop

    }
    catch {
        Write-Verbose "Couldn't retrieve federation data for domain: $DomainName"
    }

    if ($openIDResponse.token_endpoint) {
        $openIDResponse.token_endpoint.split('/')[3]
    }
}
