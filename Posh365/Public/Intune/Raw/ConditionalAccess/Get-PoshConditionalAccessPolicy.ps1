function Get-PoshConditionalAccessPolicy {
    [CmdletBinding()]
    param (

    )
    if ([datetime]::UtcNow -ge $Script:TimeToRefresh) { Connect-PoshGraphRefresh }
    $RestSplat = @{
        Uri     = "https://graph.microsoft.com/beta/identity/conditionalAccess/policies"
        Headers = @{ "Authorization" = "Bearer $Token" }
        Method  = 'Get'
    }
    Invoke-RestMethod @RestSplat -Verbose:$false | Select-Object -ExpandProperty value

}
