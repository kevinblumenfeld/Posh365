function Get-GraphRole {
    [CmdletBinding()]
    param (
        [Parameter()]
        $Id
    )
    if ([datetime]::UtcNow -ge $Script:TimeToRefresh) { Connect-PoshGraphRefresh }
    $RestSplat = @{
        Uri     = 'https://graph.microsoft.com/beta/directoryRoles/{0}' -f $Id
        Headers = @{ "Authorization" = "Bearer $Token" }
        Method  = 'Get'
    }
    Invoke-RestMethod @RestSplat -Verbose:$false | Select-Object -expandproperty Value

}
