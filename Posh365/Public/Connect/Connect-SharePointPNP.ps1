function Connect-SharePointPNP {

    [CmdletBinding(SupportsShouldProcess = $true)]
    Param
    (

        [Parameter(Mandatory)]
        [string]
        $Url

    )
    end {
        if ( -not (Get-Module -ListAvailable SharePointPnPPowerShellOnline)) {
            Install-Module SharePointPnPPowerShellOnline -Scope CurrentUser -Force -AllowClobber
        }
        Connect-PnPOnline -Url $Url -UseWebLogin
    }
}
