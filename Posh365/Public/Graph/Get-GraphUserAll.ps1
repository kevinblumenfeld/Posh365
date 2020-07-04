function Get-GraphUserAll {
    [CmdletBinding()]
    param ()
    $RestSplat = @{
        Uri     = 'https://graph.microsoft.com/beta/users'
        Headers = @{ "Authorization" = "Bearer $Token" }
        Method  = 'Get'
    }
    do {
        try {
            if ([datetime]::UtcNow -ge $Script:TimeToRefresh) { Connect-PoshGraphRefresh }
            $Response = Invoke-RestMethod @RestSplat -Verbose:$false -ErrorAction Stop
            if ($Response.'@odata.nextLink' -match 'skip') { $Next = $Response.'@odata.nextLink' }
            else { $Next = $null }
            $RestSplat = @{
                Uri     = $Next
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'Get'
            }
            foreach ($User in $Response.value) { $User }
        }
        catch { Write-Host "$User - $($_.Exception.Message)" -ForegroundColor Red }
    } until (-not $next)
}
