function Get-GraphUserAll {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Tenant
    )

    Connect-PoshGraph -Tenant $Tenant

    $Headers = @{ "Authorization" = "Bearer $Token" }
    $RestSplat = @{
        # Uri     = 'https://graph.microsoft.com/beta/users?$filter=userType eq ''Member'''
        # Uri     = 'https://graph.microsoft.com/beta/users?$filter=endswith(mail,''kevdev.onmicrosoft.com'')'
        Uri     = 'https://graph.microsoft.com/beta/users'
        Headers = $Headers
        Method  = 'Get'
    }
    do {
        try {
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
