function Get-MemMobileAppData {
    [CmdletBinding()]
    param (
        [Parameter]
        $AppId,

        [Parameter(ParameterSetName = 'Name')]
        $Name
    )
    if ([datetime]::UtcNow -ge $TimeToRefresh) { Connect-PoshGraphRefresh }
    switch ($PSCmdlet.ParameterSetName) {
        'Name' {
            # $Uri = "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps/?`$filter=(isof('microsoft.graph.managedIOSStoreApp') and microsoft.graph.managedApp/appAvailability eq microsoft.graph.managedAppAvailability'lineOfBusiness') or isof('microsoft.graph.iosLobApp') or isof('microsoft.graph.iosStoreApp') or isof('microsoft.graph.iosVppApp') or isof('microsoft.graph.managedIOSLobApp') or (isof('microsoft.graph.managedIOSStoreApp'))&`$search=$Name"
            $Uri = "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps/?`$filter=displayName eq '$Name'"
        }
        default {
            $Uri = 'https://graph.microsoft.com/beta/deviceAppManagement/mobileApps/{0}?$expand=assignments' -f $AppId
        }
    }

    $RestSplat = @{
        Uri     = $Uri
        Headers = @{ "Authorization" = "Bearer $Token" }
        Method  = 'Get'
    }
    Invoke-RestMethod @RestSplat -Verbose:$false #| Select-Object -ExpandProperty Value
}
