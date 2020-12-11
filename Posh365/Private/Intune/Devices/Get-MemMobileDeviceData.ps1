function Get-MemMobileDeviceData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $imei

    )
    if ([datetime]::UtcNow -ge $TimeToRefresh) { Connect-PoshGraphRefresh }
    $RestSplat = @{
        Uri     = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/?`$filter=imei eq '$imei'"
        Headers = @{ "Authorization" = "Bearer $Token" }
        Method  = 'Get'
    }
    Invoke-RestMethod @RestSplat -Verbose:$false | Select-Object -ExpandProperty Value

}
