function Connect-OktaSecure {
    param (
        [Parameter(Mandatory)]
        [String] $Tenant,

        [Parameter()]
        [switch] $DeleteCreds


    )
    if (-not (Get-Module -ListAvailable Okta.Core.Automation)) {
        Install-Module Okta.Core.Automation -Force -SkipPublisherCheck -Scope CurrentUser
    }
    $host.ui.RawUI.WindowTitle = "OKTA Tenant: $($Tenant.ToUpper())"
    $RootPath = $env:USERPROFILE + "\ps\"
    $KeyPath = $Rootpath + "creds\"

    if ($DeleteCreds) {
        Remove-Item ($KeyPath + "$($Tenant).OktaXml")
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
    if (Test-Path ($KeyPath + "$($Tenant).OktaXml")) {
        [System.Management.Automation.PSCredential]$Script:OKTACredential = Import-Clixml ($KeyPath + "$($Tenant).OktaXml")
        $url = $OKTACredential.GetNetworkCredential().username
        $token = $OKTACredential.GetNetworkCredential().Password

    }
    else {
        [System.Management.Automation.PSCredential]$Script:OKTACredential = Get-Credential -Message "If Okta tenant is contoso.okta.com use CONTOSO as Username and API Token as Password"
        $OKTACredential | Export-Clixml ($KeyPath + "$($Tenant).OktaXml")
        $url = $OKTACredential.GetNetworkCredential().username
        $token = $OKTACredential.GetNetworkCredential().Password
    }
    $domain = "https://$url.okta.com"

    Connect-Okta -Token $token -FullDomain $domain

}
