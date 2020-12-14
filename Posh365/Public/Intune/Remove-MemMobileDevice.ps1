function Remove-MemMobileDevice {
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        $Id
    )
    process {
        foreach ($i in $Id) {
            if ([datetime]::UtcNow -ge $TimeToRefresh) { Connect-PoshGraphRefresh }
            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/beta/deviceManagement/managedDevices/{0}" -f $I
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'Delete'
            }
            Invoke-RestMethod @RestSplat -Verbose:$false
        }
    }
}
