function Connect-SharePointPNP {

    [CmdletBinding(SupportsShouldProcess = $true)]
    Param
    (

        [Parameter(Mandatory)]
        [string]
        $Url

    )
    end {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        if ( -not (Get-Module -ListAvailable SharePointPnPPowerShellOnline)) {
            Install-Module SharePointPnPPowerShellOnline -Scope CurrentUser -Force -AllowClobber
        }
        Connect-PnPOnline -Url $Url -UseWebLogin
    }
}
