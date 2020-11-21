function Get-MemMobileAppConfigData {
    [CmdletBinding()]
    param (

    )
    if ([datetime]::UtcNow -ge $Global:TimeToRefresh) { Connect-PoshGraphRefresh }
    $RestSplat = @{
        Uri     = 'https://graph.microsoft.com/beta/deviceAppManagement/mobileAppConfigurations?$expand=assignments'
        Headers = @{ "Authorization" = "Bearer $Token" }
        Method  = 'Get'
    }
    Invoke-RestMethod @RestSplat -Verbose:$false | Select-Object -ExpandProperty Value

}
