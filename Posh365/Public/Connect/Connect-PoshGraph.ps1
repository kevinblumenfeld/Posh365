function Connect-PoshGraph {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Tenant,

        [Parameter()]
        [switch]
        $DeleteCreds
    )
    $TenantPath = Join-Path -Path $Env:USERPROFILE -ChildPath ('.Posh365/Credentials/Graph/{0}' -f $Tenant)
    $TenantCred = Join-Path -Path $TenantPath -ChildPath ('{0}Cred.xml' -f $Tenant)
    $TenantConfig = Join-Path -Path $TenantPath -ChildPath ('{0}Config.xml' -f $Tenant)
    $TImport = Import-Clixml $TenantConfig

    [System.Management.Automation.PSCredential]$TConfig = $TImport.Cred
    $TS = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($TConfig.Password)
    $TenantSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($TS)

    [System.Management.Automation.PSCredential]$TCred = Import-Clixml -Path $TenantCred
    $TP = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($TCred.Password)
    $TPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($TP)

    $Request = @{
        Method = 'POST'
        Body   = @{
            Grant_Type    = 'PASSWORD'
            Client_Id     = $TImport.ClientId
            Client_Secret = $TenantSecret
            Username      = $TCred.UserName
            Password      = $TPass
            Scope         = "offline_access https://graph.microsoft.com/.default"
        }
        Uri    = 'https://login.microsoftonline.com/{0}/oauth2/v2.0/token' -f $TConfig.Username
    }
    $TenantResponse = Invoke-RestMethod @Request
    $Script:TimeToRefresh = ([datetime]::UtcNow).AddSeconds($TenantResponse.expires_in - 10)
    $Script:Token = $TenantResponse.access_token
    $Script:RefreshToken = $TenantResponse.refresh_token
}
