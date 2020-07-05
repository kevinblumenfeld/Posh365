function Get-GraphUserAll {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $IncludeGuests
    )
    if (-not $IncludeGuests) {
        $uri = "https://graph.microsoft.com/beta/users/?`$filter=userType eq 'Member'"
    }
    else { $Uri = 'https://graph.microsoft.com/beta/users' }

    $RestSplat = @{
        Uri     = $Uri
        Headers = @{ "Authorization" = "Bearer $Token" }
        Method  = 'Get'
    }
    do {
        try {
            if ([datetime]::UtcNow -ge $Script:TimeToRefresh) { Connect-PoshGraphRefresh }
            (Invoke-RestMethod @RestSplat -Verbose:$false -ErrorAction Stop).value
            if ($Response.'@odata.nextLink' -match 'skip') { $Next = $Response.'@odata.nextLink' }
            else { $Next = $null }
            $RestSplat = @{
                Uri     = $Next
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'Get'
            }
        }
        catch { Write-Host "Error: $UPN - $($_.Exception.Message)" -ForegroundColor Red }
    } until (-not $next)
}
