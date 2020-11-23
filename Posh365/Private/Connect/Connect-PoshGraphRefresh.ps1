function Connect-PoshGraphRefresh {
    [CmdletBinding()]
    param (    )

    $TenantPath = Join-Path -Path $Env:USERPROFILE -ChildPath ('.Posh365/Credentials/Graph/{0}' -f $Tenant)

    if (-not $AppOnly) {
        # Delegate flow (Creds)
        $TenantCred = Join-Path -Path $TenantPath -ChildPath ('{0}Cred.xml' -f $Tenant)
        [PSCredential]$Credential = Import-Clixml -Path $TenantCred
        $MarshalPassword = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password)
        $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($MarshalPassword)
    }

    # Application flow (Config)
    $TenantConfig = Join-Path -Path $TenantPath -ChildPath ('{0}Config.xml' -f $Tenant)
    $XML = Import-Clixml $TenantConfig
    [PSCredential]$Configuration = $XML.Cred
    $MarshalSecret = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Configuration.Password)
    $Secret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($MarshalSecret)

    $Request = if ($AppOnly) {
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
        @{
            Method = 'POST'
            Body   = @{
                Grant_Type    = 'refresh_token'
                Client_Id     = $XML.ClientId
                Client_Secret = $Secret
                Username      = $Credential.UserName
                Password      = $Password
                refresh_token = $RefreshToken
                Scope         = "offline_access https://graph.microsoft.com/.default"
            }
            Uri    = 'https://login.microsoftonline.com/{0}/oauth2/v2.0/token' -f $Configuration.Username
        }
    }

    $TenantResponse = Invoke-RestMethod @Request
    $Script:TimeToRefresh = ([datetime]::UtcNow).AddSeconds($TenantResponse.expires_in - 10)
    $Script:Token = $TenantResponse.access_token

}
