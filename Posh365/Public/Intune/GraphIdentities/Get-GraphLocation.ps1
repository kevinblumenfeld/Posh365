function Get-GraphLocation {
    [CmdletBinding()]
    param (
        [Parameter()]
        $Id
    )
    if ([datetime]::UtcNow -ge $Script:TimeToRefresh) { Connect-PoshGraphRefresh }
    $RestSplat = @{
        Uri     = 'https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations/{0}' -f $Id
        Headers = @{ "Authorization" = "Bearer $Token" }
        Method  = 'Get'
    }
    Invoke-RestMethod @RestSplat -Verbose:$false

}
