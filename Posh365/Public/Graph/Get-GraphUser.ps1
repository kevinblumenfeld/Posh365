function Get-GraphUser {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string]
        $Tenant,

        [Parameter(ValueFromPipeline)]
        $UserPrincipalName
    )
    begin {
        if (-not $UserPrincipalName) { $UserPrincipalName = (Get-GraphUserAll -Tenant $Tenant).Id }
    }
    process {
        foreach ($UPN in $UserPrincipalName) {
            if ([datetime]::UtcNow -ge $Script:TimeToRefresh) { Connect-PoshGraphRefresh }
            $RestSplat = @{
                Uri     = 'https://graph.microsoft.com/v1.0/users/{0}' -f $UPN
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'Get'
            }
            try { Invoke-RestMethod @RestSplat -Verbose:$false -ErrorAction Stop }
            catch { Write-Host "$User - $($_.Exception.Message)" -ForegroundColor Red }
        }
    }
}
