function New-GraphUser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Tenant,

        [Parameter(ValueFromPipeline)]
        $UserList
    )
    process {
        foreach ($User in $UserList) {
            if ([datetime]::UtcNow -ge $Script:TimeToRefresh) { Connect-PoshGraphRefresh }
            $Headers = @{
                'Authorization' = "Bearer $Token"
                'Content-Type'  = 'application/json'
            }
            $test = @{
                'accountEnabled'    = $true
                'mailnickname'      = ''
                'userPrincipalName' = ''
                'displayName'       = ''
                'passwordProfile'   = @{
                    'password'                      = ''
                    'forceChangePasswordNextSignIn' = $true
                }
            }
            $RestSplat = @{
                Uri     = 'https://graph.microsoft.com/v1.0/users'
                Headers = $Headers
                Method  = 'POST'
                Body    = ($test | ConvertTo-Json)
            }
            try { Invoke-RestMethod @RestSplat -Verbose:$false -ErrorAction Stop }
            catch { write-host "Error: $($_.Exception.Message)" -ForegroundColor Red }
        }
    }
}
