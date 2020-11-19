function Get-MemMobileAppConfig {
    [CmdletBinding()]
    param (

    )
    if ([datetime]::UtcNow -ge $Script:TimeToRefresh) { Connect-PoshGraphRefresh }
    $RestSplat = @{
        Uri     = 'https://graph.microsoft.com/beta/deviceAppManagement/mobileAppConfigurations?$expand=assignments'
        Headers = @{ "Authorization" = "Bearer $Token" }
        Method  = 'Get'
    }
    Invoke-RestMethod @RestSplat -Verbose:$false | Select-Object -ExpandProperty Value

}
