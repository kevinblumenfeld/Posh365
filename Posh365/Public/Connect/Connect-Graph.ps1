function Connect-Graph {
    [CmdletBinding()]
    param(

        [Parameter(Mandatory, HelpMessage = "Use either format, tenant or tenant.onmicrosoft.com")]
        [ValidateNotNullOrEmpty()]
        [string] $Tenant,

        [Parameter()]
        [string] $Identifier,

        [Parameter()]
        [switch] $DeleteCreds

    )
    if ($Tenant -notmatch ".onmicrosoft.com") {
        $Tenant = $Tenant + ".onmicrosoft.com"
    }
    $host.ui.RawUI.WindowTitle = "Azure Tenant: $($Tenant.ToUpper())"
    $RootPath = $env:USERPROFILE + "\ps\"
    $KeyPath = $Rootpath + "creds\"

    if ($Identifier) {
        $TenantAndID = $Tenant + $Identifier
    }
    else {
        $TenantAndID = $Tenant
    }


    if ($DeleteCreds) {
        Remove-Item ($KeyPath + "$($TenantAndID).AzureXml")
        break
    }
    # Create KeyPath Directory
    if (-not (Test-Path $KeyPath)) {
        Try {
            $null = New-Item -ItemType Directory -Path $KeyPath -ErrorAction STOP
        }
        Catch {
            throw $_.Exception.Message
        }
    }
    if (Test-Path ($KeyPath + "$($TenantAndID).AzureXml")) {
        [System.Management.Automation.PSCredential]$Script:AzureCredential = Import-Clixml ($KeyPath + "$($TenantAndID).AzureXml")
        $ClientID = $AzureCredential.GetNetworkCredential().username
        $Secret = $AzureCredential.GetNetworkCredential().Password

    }
    else {
        [System.Management.Automation.PSCredential]$Script:AzureCredential = Get-Credential -Message "Enter Application ID (client id) as Username and API Secret as Password"
        $AzureCredential | Export-Clixml ($KeyPath + "$($TenantAndID).AzureXml")
        $ClientID = $AzureCredential.GetNetworkCredential().username
        $Secret = $AzureCredential.GetNetworkCredential().Password
    }

    $loginRequest = @{
        Method = "Post"
        Body   = @{
            'client_id'     = $ClientID
            'client_secret' = $Secret
            'grant_type'    = 'client_credentials'
            'scope'         = 'https://graph.microsoft.com/.default'
            'resource'      = 'https://graph.microsoft.com/'
        }
        Uri    = "https://login.microsoftonline.com/$Tenant/oauth2/token"
    }

    try {
        $Session = Invoke-RestMethod @loginRequest
    }
    catch {
        Write-Error 'Could not get the session. incorrect app or account?'
        throw $_
    }
    #$Session
    $Session.access_token
}