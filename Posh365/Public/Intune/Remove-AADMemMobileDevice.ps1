function Remove-AADMemMobileDevice {
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        $Id
    )
    process {
        foreach ($i in $Id) {
            if ([datetime]::UtcNow -ge $TimeToRefresh) { Connect-PoshGraphRefresh }
            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/beta/devices/{0}" -f $i
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'Delete'
            }
            Invoke-RestMethod @RestSplat -Verbose:$false
        }
    }
}
