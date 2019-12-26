function Test-O365IsFederated {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainData
    )

    # Check if we have any federation data for this domain
    if ($DomainData.FEDERATION -eq $null) { return "N/A" }

    if ($DomainData.FEDERATION.NameSpaceType -eq 'Federated') {
        return $true
    }
    else {
        return $false
    }
}
