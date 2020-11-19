function Get-GraphGroup {
    [CmdletBinding()]
    param (
        [Parameter()]
        $GroupId
    )
    if ([datetime]::UtcNow -ge $Script:TimeToRefresh) { Connect-PoshGraphRefresh }
    $RestSplat = @{
        Uri     = 'https://graph.microsoft.com/beta/groups/{0}' -f $GroupId
        Headers = @{ "Authorization" = "Bearer $Token" }
        Method  = 'Get'
    }
    Invoke-RestMethod @RestSplat -Verbose:$false

}
