function Set-MemMobileDevice {
    param (
        [Parameter(Mandatory, ParameterSetName = 'Action', ValueFromPipelineByPropertyName)]
        $Id,

        [Parameter(Mandatory, ParameterSetName = 'Action')]
        [ValidateSet('Retire')]
        $Action
    )
    process {
        foreach ($i in $Id) {
            if ([datetime]::UtcNow -ge $TimeToRefresh) { Connect-PoshGraphRefresh }
            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/beta/deviceManagement/managedDevices/{0}/retire" -f $i
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'Post'
            }
            Invoke-RestMethod @RestSplat -Verbose:$false
        }
    }
}
