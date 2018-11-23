function Connect-OktaSecure {
    param (
        [Parameter(Mandatory)]
        [String] $Tenant,

        [Parameter()]
        [switch] $DeleteCreds
        
        
    )
    if (-not (Get-Module -ListAvailable Okta.Core.Automation)) {
        Install-Module Okta.Core.Automation -Force -SkipPublisherCheck
    }
    $host.ui.RawUI.WindowTitle = "OKTA Tenant: $($Tenant.ToUpper())"
    $RootPath = $env:USERPROFILE + "\ps\"
    $KeyPath = $Rootpath + "creds\"

    if ($DeleteCreds) {
        Remove-Item ($KeyPath + "$($Tenant).OktaXml")
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
    if (Test-Path ($KeyPath + "$($Tenant).OktaXml")) {
        [System.Management.Automation.PSCredential]$Global:Credential = Import-Clixml ($KeyPath + "$($Tenant).OktaXml")
        $url = $Credential.GetNetworkCredential().username
        $token = $Credential.GetNetworkCredential().Password

    }
    else {
        [System.Management.Automation.PSCredential]$Global:Credential = Get-Credential -Message "Enter OKTA Tenant/Domain as Username and API Token as Password"
        $Credential | Export-Clixml ($KeyPath + "$($Tenant).OktaXml")
        $url = $Credential.GetNetworkCredential().username
        $token = $Credential.GetNetworkCredential().Password
    }
    $domain = "https://$url.okta.com"

    Connect-Okta -Token $token -FullDomain $domain

}
