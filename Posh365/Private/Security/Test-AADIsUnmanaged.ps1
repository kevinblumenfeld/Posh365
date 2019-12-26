function Test-AADIsUnmanaged {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainData
    )
    if ($DomainData.FEDERATION -eq $null) { return "N/A" }

    if ($DomainData.FEDERATION.IsViral -eq $null) { return $false }

    $DomainData.FEDERATION.IsViral
}
