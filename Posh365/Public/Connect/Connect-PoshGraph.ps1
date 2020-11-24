function Connect-PoshGraph {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Tenant,

        [Parameter()]
        [switch]
        $AppOnly,

        [Parameter()]
        [switch]
        $DeleteCreds
    )

    $Script:Tenant = $Tenant
    if (-not $AppOnly) { $AppOnly = $null } else { $Script:AppOnly = $AppOnly }
    $host.ui.RawUI.WindowTitle = "Tenant: $($Tenant.ToUpper())"
    $TenantPath = Join-Path -Path $Env:USERPROFILE -ChildPath ('.Posh365/Credentials/Graph/{0}' -f $Script:Tenant)

    # Application flow (Config)
    $TenantConfig = Join-Path -Path $TenantPath -ChildPath ('{0}Config.xml' -f $Script:Tenant)
    $XML = Import-Clixml $TenantConfig
    [PSCredential]$Configuration = $XML.Cred
    $MarshalSecret = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Configuration.Password)
    $Secret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($MarshalSecret)

    # Delegate flow (Creds)
    $TenantCred = Join-Path -Path $TenantPath -ChildPath ('{0}Cred.xml' -f $Script:Tenant)
    if (-not (Test-Path $TenantCred)) { $Script:AppOnly = $true }

    if ($DeleteCreds) {
        Remove-Item -Path $TenantConfig, $TenantCred -Force -ErrorAction SilentlyContinue
        continue
    }
    $Request = if ($Script:AppOnly) {
        @{
            Method = 'POST'
            Body   = @{
                Grant_Type    = 'client_credentials'
                Client_Id     = $XML.ClientId
                Client_Secret = $Secret
                scope         = 'offline_access https://graph.microsoft.com/.default'
                resource      = 'https://graph.microsoft.com/' #this neeeds to be removed
            }
            Uri    = 'https://login.microsoftonline.com/{0}/oauth2/token' -f $Configuration.Username
        }
    }
    else {
        # Delegate flow (Creds)
        [PSCredential]$Credential = Import-Clixml -Path $TenantCred
        $MarshalPassword = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password)
        $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($MarshalPassword)
        @{
            Method = 'POST'
            Body   = @{
                Grant_Type    = 'PASSWORD'
                Client_Id     = $XML.ClientId
                Client_Secret = $Secret
                Scope         = "offline_access https://graph.microsoft.com/.default"
                Username      = $Credential.UserName
                Password      = $Password
            }
            Uri    = 'https://login.microsoftonline.com/{0}/oauth2/v2.0/token' -f $Configuration.Username
        }
    }
    $TenantResponse = Invoke-RestMethod @Request
    $Script:TimeToRefresh = ([datetime]::UtcNow).AddSeconds($TenantResponse.expires_in - 10)
    $Script:Token = $TenantResponse.access_token
    $Script:RefreshToken = $TenantResponse.refresh_token
}
