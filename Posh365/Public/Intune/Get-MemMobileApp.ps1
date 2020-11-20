function Get-MemMobileApp {
    [CmdletBinding()]
    param (
        [Parameter()]
        $AppId
    )
    if ([datetime]::UtcNow -ge $Script:TimeToRefresh) { Connect-PoshGraphRefresh }
    $RestSplat = @{
        Uri     = 'https://graph.microsoft.com/beta/deviceAppManagement/mobileApps/{0}' -f $AppId
        Headers = @{ "Authorization" = "Bearer $Token" }
        Method  = 'Get'
    }
    Invoke-RestMethod @RestSplat -Verbose:$false | Select-Object -ExpandProperty Value
}
