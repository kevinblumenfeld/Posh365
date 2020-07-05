function Get-GraphUser {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]
        $UserPrincipalName
    )
    begin {
        if (-not $MyInvocation.ExpectingInput -and -not $PSBoundParameters.ContainsKey('UserPrincipalName')) { Get-GraphUserAll }
    }
    process {
        foreach ($UPN in $UserPrincipalName) {
            if ([datetime]::UtcNow -ge $Script:TimeToRefresh) { Connect-PoshGraphRefresh }
            $RestSplat = @{
                Uri     = 'https://graph.microsoft.com/beta/users/{0}' -f $UPN
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'Get'
            }
            try { Invoke-RestMethod @RestSplat -Verbose:$false -ErrorAction Stop }
            catch { Write-Host "Error: $UPN - $($_.Exception.Message)" -ForegroundColor Red }
        }
    }
}
