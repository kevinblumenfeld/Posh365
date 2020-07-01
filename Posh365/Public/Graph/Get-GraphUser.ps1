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
        Connect-PoshGraph -Tenant $Tenant
        if (-not $UserPrincipalName) { $UserPrincipalName = (Get-GraphUserAll -Tenant $Tenant).Id }
    }
    process {
        foreach ($UPN in $UserPrincipalName) {
            $RestSplat = @{
                Uri     = 'https://graph.microsoft.com/beta/users/{0}' -f $UPN
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'Get'
            }
            try { Invoke-RestMethod @RestSplat -Verbose:$false -ErrorAction Stop }
            catch { Write-Host "$User - $($_.Exception.Message)" -ForegroundColor Red }
        }
    }
}
