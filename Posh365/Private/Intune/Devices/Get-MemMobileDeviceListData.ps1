function Get-MemMobileDeviceListData {
    [CmdletBinding()]
    param (

    )
    if ([datetime]::UtcNow -ge $TimeToRefresh) { Connect-PoshGraphRefresh }
    $RestSplat = @{
        Uri     = "https://graph.microsoft.com/beta/deviceManagement/managedDevices"
        Headers = @{ "Authorization" = "Bearer $Token" }
        Method  = 'Get'
    }
    do {
        if ([datetime]::UtcNow -ge $TimeToRefresh) { Connect-PoshGraphRefresh }
        $Response = Invoke-RestMethod @RestSplat -Verbose:$false
        $Response.value
        if ($Response.'@odata.nextLink' -match 'skip') { $Next = $Response.'@odata.nextLink' }
        else { $Next = $null }
        $RestSplat = @{
            Uri     = $Next
            Headers = @{ "Authorization" = "Bearer $Token" }
            Method  = 'Get'
        }
    } until (-not $next)
}
