function Connect-EXOPSSession {
    <#
        .SYNOPSIS
            To connect in other Office 365 offerings, use the following settings:
            - Office 365 operated by 21Vianet: -ConnectionURI https://partner.outlook.cn/PowerShell-LiveID -AzureADAuthorizationEndpointUri https://login.chinacloudapi.cn/common
            - Office 365 Germany: -ConnectionURI https://outlook.office.de/PowerShell-LiveID -AzureADAuthorizationEndpointUri https://login.microsoftonline.de/common

            - PSSessionOption accept object created using New-PSSessionOption
        .DESCRIPTION
            This PowerShell module allows you to connect to Exchange Online service
        .LINK
            https://go.microsoft.com/fwlink/p/?linkid=837645
    #>

    param(
        # Connection Uri for the Remote PowerShell endpoint
        [string] $ConnectionUri = 'https://outlook.office365.com/PowerShell-LiveId',

        # Azure AD Authorization endpoint Uri that can issue the OAuth2 access tokens
        [string] $AzureADAuthorizationEndpointUri = 'https://login.windows.net/common',

        # User Principal Name or email address of the user
        [string] $UserPrincipalName = '',

        # PowerShell session options to be used when opening the Remote PowerShell session
        [System.Management.Automation.Remoting.PSSessionOption] $PSSessionOption = $null,

        # User Credential to Logon
        [System.Management.Automation.PSCredential] $Credential = $null
    )

    # Validate parameters
    if (-not (Test-Uri $ConnectionUri)) {
        throw "Invalid ConnectionUri parameter '$ConnectionUri'"
    }
    if (-not (Test-Uri $AzureADAuthorizationEndpointUri)) {
        throw "Invalid AzureADAuthorizationEndpointUri parameter '$AzureADAuthorizationEndpointUri'"
    }

    try {
        $modules = @(Get-ChildItem -Path "$($env:LOCALAPPDATA)\Apps\2.0" -Filter "Microsoft.Exchange.Management.ExoPowershellModule.manifest" -Recurse )
        $ModulePath = Join-Path $modules[0].Directory.FullName "Microsoft.Exchange.Management.ExoPowershellModule.dll"
        # $ExoPowershellModule = "Microsoft.Exchange.Management.ExoPowershellModule.dll";
        # $ModulePath = [System.IO.Path]::Combine($PSScriptRoot, $ExoPowershellModule);

        $global:ConnectionUri = $ConnectionUri;
        $global:AzureADAuthorizationEndpointUri = $AzureADAuthorizationEndpointUri;
        $global:UserPrincipalName = $UserPrincipalName;
        $global:PSSessionOption = $PSSessionOption;
        $global:Credential = $Credential;

        Import-Module $ModulePath -DisableNameChecking -WarningAction SilentlyContinue
        $PSSplat = @{
            UserPrincipalName               = $UserPrincipalName
            ConnectionUri                   = $ConnectionUri
            AzureADAuthorizationEndpointUri = $AzureADAuthorizationEndpointUri
            PSSessionOption                 = $PSSessionOption
            Credential                      = $Credential
            WarningAction                   = 'SilentlyContinue'
        }
        $PSSession = New-ExoPSSession @PSSplat

        if ($PSSession -ne $null) {
            Import-PSSession $PSSession -AllowClobber -DisableNameChecking -WarningAction SilentlyContinue
            Get-RemotingHandler
        }
    }
    catch {
        throw "YOU CAN SAFELY IGNORE THIS ERROR - YOU WILL NOT SEE IT AGAIN"
    }
}
