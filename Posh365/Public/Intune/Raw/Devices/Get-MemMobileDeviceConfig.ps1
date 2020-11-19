function Get-MemMobileDeviceConfig {
    [CmdletBinding()]
    param (

    )
    if ([datetime]::UtcNow -ge $Script:TimeToRefresh) { Connect-PoshGraphRefresh }
    $RestSplat = @{
        Uri     = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations?`$filter=isof('microsoft.graph.iosWiFiConfiguration')&`$expand=assignments"
        # Uri     = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations?`$filter=isof('microsoft.graph.iosEasEmailProfileConfiguration')&`$expand=assignments"
        # Uri     = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations?`$filter=isof('microsoft.graph.iosGeneralDeviceConfiguration')&`$expand=assignments"
        # Uri     = "https://graph.microsoft.com/beta/deviceManagement/getRoleScopeTagsByResource(resource='DeviceConfigurations')"
        # Uri     = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations?`$filter=isof('microsoft.graph.windowsUpdateForBusinessConfiguration')&`$expand=assignments"
        # Uri     = "https://graph.microsoft.com/beta/deviceAppManagement/mobileAppConfigurations?`$expand=assignments&filter=microsoft.graph.androidManagedStoreAppConfiguration/appSupportsOemConfig eq false"
        # Uri     = "https://graph.microsoft.com/v1.0/deviceManagement/deviceConfigurations?`$filter={0} eq '{1}'" -f 'id', 'db86ae76-c0d3-4a42-b2ae-8472413f17e2'
        Headers = @{ "Authorization" = "Bearer $Token" }
        Method  = 'Get'
    }
    Invoke-RestMethod @RestSplat -Verbose:$false | Select-Object -ExpandProperty value

}
