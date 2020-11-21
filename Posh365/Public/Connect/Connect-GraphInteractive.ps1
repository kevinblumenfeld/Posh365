function Connect-GraphInteractive {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Tenant,

        [Parameter()]
        [string]
        $App,

        [Parameter()]
        [switch]
        $AppOnly,

        [Parameter()]
        [switch]
        $DeleteCreds
    )

    $host.ui.RawUI.WindowTitle = "Tenant: $($Tenant.ToUpper())"
    $TenantPath, $TenantConfig, $TenantCred, $AppOnly, $TimeToRefresh, $Token, $RefreshToken = $null
    $Global:Tenant = $Tenant
    $Global:TenantPath = Join-Path -Path $Env:USERPROFILE -ChildPath ('.Posh365/Credentials/Graph/{0}' -f $Global:Tenant)

    # Application flow
    $Global:TenantConfig = Join-Path -Path $Global:TenantPath -ChildPath ('{0}Config.xml' -f $Global:Tenant)
    $XML = Import-Clixml $Global:TenantConfig

    # Delegate flow
    $Global:TenantCred = Join-Path -Path $Global:TenantPath -ChildPath ('{0}Cred.xml' -f $Global:Tenant)
    if ($Applicationonly -or -not (Test-Path $Global:TenantCred)) {
        $Global:AppOnly = $true
        [PSCredential]$Configuration = $XML.Cred
        $MarshalSecret = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Configuration.Password)
        $Secret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($MarshalSecret)
    }
    if ($DeleteCreds) {
        Remove-Item -Path $TenantConfig, $TenantCred -Force -ErrorAction SilentlyContinue
        continue
    }

    $Request = if ($Global:AppOnly) {
        @{
            Method = "Post"
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
        [PSCredential]$Credential = Import-Clixml -Path $Global:TenantCred
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
    $Global:TimeToRefresh = ([datetime]::UtcNow).AddSeconds($TenantResponse.expires_in - 10)
    $Global:Token = $TenantResponse.access_token
    $Global:RefreshToken = $TenantResponse.refresh_token
}
