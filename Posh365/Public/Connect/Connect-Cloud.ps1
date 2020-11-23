function Connect-Cloud {
    <#
    .SYNOPSIS
    Connects to Office 365 services and/or Azure.

    .DESCRIPTION
    Connects to Office 365 services and/or Azure.

    Connects to some or all of the Office 365/Azure services based on switches provided at runtime.

    Office 365 tenant name, for example, either contoso or contoso.onmicrosoft.com must be provided with -Tenant parameter.
    The -Tenant parameter is mandatory.

    There is a switch to use Multi-Factor Authentication.
    For Exchange Online MFA, you are required to download and use the Exchange Online Remote PowerShell Module.
    To download the Exchange Online Remote PowerShell Module for multi-factor authentication ONCE, in the EAC (https://outlook.office365.com/ecp/), go to Hybrid \> Setup and click the appropriate Configure button.
    When using Multi-Factor Authentication the saving of credentials is not available currently - thus each service will prompt independently for credentials.

    Locally saves and encrypts to a file the username and password.
    The encrypted file...can only be used on the computer and within the user's profile from which it was created, is the same .txt file for all the Office 365 services and is a separate .json file for Azure.
    If a username or password becomes corrupt or is entered incorrectly, it can be deleted using -DeleteCreds.
    For example, Connect-Cloud Contoso -DeleteCreds

    If Azure switch is used for first time :

    1. User will login as normal when prompted by Azure
    2. User will be prompted to select which Azure Subscription
    3. Select the subscription and click "OK"

    If Azure switch is used after first time:

    1. User will be prompted to pick username used previously
    2. If a new username is to be used (e.g.username not found when prompted), click Cancel to be prompted to login.
    3. User will be prompted to select which Azure Subscription
    4. Select the subscription and click "OK"

    Directories used/created during the execution of this script

    1. $env:USERPROFILE\ps\
    2. $env:USERPROFILE\ps\creds\

    All saved credentials are saved in `$env:USERPROFILE\ps\creds\`
    Transcript is started and kept in `$env:USERPROFILE\ps\<tenantspecified>`

    .PARAMETER Tenant
    Mandatory parameter that specifies which Office 365 and/or Azure Tenant you want to connect to.
    If connecting to SharePoint Online, this parameter is used to used to create the URL needed to connect to SharePoint Online

    .PARAMETER ExchangeOnline
    Connects to Exchange Online

    .PARAMETER MSOnline
    Connects to Microsoft Online Service (Azure AD Version 1)

    .PARAMETER All365
    Connects to all Office 365 Services

    .PARAMETER Azure
    Connects to Azure

    .PARAMETER Skype
    Connects to Skype Online

    .PARAMETER SharePoint
    Connects to SharePoint Online

    .PARAMETER Compliance
    Connects to Security & Compliance Center

    .PARAMETER Intune
    Connects to Intue

    .PARAMETER AzureADver2
    Connects to Azure AD Version 2

    .PARAMETER MFA
    Parameter description

    .PARAMETER DeleteCreds
    Deletes your saved credentials for tenant specified

    .PARAMETER EXOPrefix
    Adds CLOUD prefix to all Exchange Online commands. For example Get-CLOUDMailbox.

    .EXAMPLE
    Connect-Cloud -Tenant Contoso -ExchangeOnline -MSOnline

    Connects to MS Online Service (MSOL) and Exchange Online

    The tenant must be specified, for example either contoso or contoso.onmicrosoft.com

    .EXAMPLE
    Connect-Cloud -Tenant Contoso -All365 -Azure

    Connects to Azure, MS Online Service (MSOL), Exchange Online, Skype, SharePoint & Compliance

    .EXAMPLE
    Connect-Cloud Contoso -Skype -Azure -ExchangeOnline -MSOnline

    Connects to Azure, MS Online Service (MSOL), Exchange Online & Skype

    This is to illustrate that any number of individual services can be used to connect.
    Also that the -Tenant parameter is positional

    #>

    [CmdletBinding(SupportsShouldProcess = $true)]
    Param
    (
        [Parameter(Position = 0, Mandatory)]
        [string]
        $Tenant,

        [Parameter()]
        [switch]
        $ExchangeOnline,

        [Parameter()]
        [switch]
        $EXO2,

        [Parameter()]
        [switch]
        $MSOnline,

        [Parameter()]
        [switch]
        $All365,

        [Parameter()]
        [switch]
        $Skype,

        [Parameter()]
        [switch]
        $Teams,

        [Parameter()]
        [switch]
        $SharePoint,

        [Parameter()]
        [switch]
        $Compliance,

        [Parameter()]
        [switch]
        $Intune,

        [Parameter()]
        [switch]
        $Az,

        [Parameter()]
        [Alias('AzureADver2')]
        [switch]
        $AzureAD,

        [Parameter()]
        [switch]
        $MFA,

        [Parameter()]
        [switch]
        $GCCHIGH,

        [Parameter()]
        [switch]
        $DeleteCreds,

        [Parameter()]
        [switch]
        $EXOPrefix
    )
    if ($Tenant -like '*.onmicrosoft.com') { $Tenant = $Tenant.Split('.')[0] }

    $host.ui.RawUI.WindowTitle = "Tenant: $($Tenant.ToUpper())"
    $RootPath = $env:USERPROFILE + "\ps\"
    $KeyPath = $Rootpath + "creds\"
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    if ($DeleteCreds) {
        try {
            Remove-Item ($KeyPath + "$($Tenant).cred") -ErrorAction Stop
        }
        catch {
            Write-Warning "While the attempt to delete credentials failed, this may be normal. Please try to connect again."
        }
        try {
            Remove-Item ($KeyPath + "$($Tenant).ucred") -ErrorAction Stop
        }
        catch {
            break
        }
    }
    if (-not (Test-Path ($RootPath + $Tenant + "\logs\"))) {
        New-Item -ItemType Directory -Force -Path ($RootPath + $Tenant + "\logs\")
    }
    try {
        Start-Transcript -ErrorAction Stop -path ($RootPath + $Tenant + "\logs\" + "transcript-" + ($(Get-Date -Format _yyyy-MM-dd_HH-mm-ss)) + ".txt")
    }
    catch {
        Stop-Transcript -ErrorAction SilentlyContinue
        Start-Transcript -path ($RootPath + $Tenant + "\logs\" + "transcript-" + ($(Get-Date -Format _yyyy-MM-dd_HH-mm-ss)) + ".txt")
    }
    # Create KeyPath Directory
    if (-not (Test-Path $KeyPath)) {
        try {
            $null = New-Item -ItemType Directory -Path $KeyPath -ErrorAction STOP
        }
        catch {
            throw $_.Exception.Message
        }
    }
    if (($ExchangeOnline -or $MSOnline -or $All365 -or $Skype -or
            $SharePoint -or $Compliance -or $AzureADver2 -or $AzureAD -or $EXO2 -or $Teams) -and (-not $MFA)) {
        if (Test-Path ($KeyPath + "$($Tenant).cred")) {
            $PwdSecureString = Get-Content ($KeyPath + "$($Tenant).cred") | ConvertTo-SecureString
            $UsernameString = Get-Content ($KeyPath + "$($Tenant).ucred")
            $Credential = [System.Management.Automation.PSCredential]::new($UsernameString, $PwdSecureString)
        }
        else {
            $Credential = Get-Credential -Message "ENTER USERNAME & PASSWORD FOR OFFICE 365/AZURE AD"
            if ($Credential.Password) {
                $Credential.Password | ConvertFrom-SecureString | Out-File ($KeyPath + "$($Tenant).cred") -Force
            }
            else {
                Connect-Cloud $Tenant -DeleteCreds
                Write-Warning "                 No Password Present                                "
                Write-Warning "          Please try your last command again...                     "
                Write-Warning "...you will be prompted to enter your Office 365 credentials again. "
                Break
            }
            $Credential.UserName | Out-File ($KeyPath + "$($Tenant).ucred")
        }
    }
    if ($MSOnline -or $All365) {
        if (-not ($null = Get-Module -Name MSOnline -ListAvailable -ErrorAction Stop)) {
            Install-Module -Name MSOnline -Scope CurrentUser -Force -AllowClobber
        }
        try {
            $null = Get-MsolAccountSku -ErrorAction Stop
        }
        catch {
            try {
                $MSOLSplat = @{
                    Credential  = $Credential
                    ErrorAction = 'Stop'
                    Verbose     = $false
                }
                if ($GCCHIGH) {
                    $MSOLSplat['AzureEnvironment'] = 'USGovernment'
                }
                Connect-MsolService @MSOLSplat
                Write-Host "You have successfully connected to MSONLINE" -foregroundcolor "magenta" -backgroundcolor "white"
            }
            catch {
                if ($_.exception.Message -match "password") {
                    Connect-Cloud $Tenant -DeleteCreds
                    Write-Warning "           Bad Username or Password.                                "
                    Write-Warning "          Please try your last command again...                     "
                    Write-Warning "...you will be prompted to enter your Office 365 credentials again. "
                    Break

                }
                else {
                    Connect-Cloud $Tenant -DeleteCreds
                    Write-Warning "     There was an error connecting you to MSOnline                  "
                    Write-Warning "          Please try your last command again...                     "
                    Write-Warning "...you will be prompted to enter your Office 365 credentials again. "
                    Break
                }
            }
        }
    }

    # Skype Online
    if ($Skype -or $All365) {
        if (-not $MFA) {
            try {
                $sfboSession = New-CsOnlineSession -ErrorAction Stop -Credential $Credential -OverrideAdminDomain "$Tenant.onmicrosoft.com"
                Write-Host "You have successfully connected to Skype" -foregroundcolor "magenta" -backgroundcolor "white"
            }
            catch [System.Management.Automation.CommandNotFoundException] {
                Write-Warning "Skype for Business Online Module not found.  Please download and install it from here:"
                Write-Warning "https://www.microsoft.com/en-us/download/details.aspx?id=39366"
            }
            catch {
                $_
            }
            Import-Module (Import-PSSession $sfboSession -AllowClobber) -Global | Out-Null
        }
        else {
            try {
                $sfboSession = New-CsOnlineSession -UserName $Credential.UserName -OverrideAdminDomain "$Tenant.onmicrosoft.com" -ErrorAction Stop
                Write-Host "You have successfully connected to Skype" -foregroundcolor "magenta" -backgroundcolor "white"
            }
            catch [System.Management.Automation.CommandNotFoundException] {
                Write-Warning "Skype for Business Online Module not found.  Please download and install it from here:"
                Write-Warning "https://www.microsoft.com/en-us/download/details.aspx?id=39366"
            }
            catch {
                $_
            }
            Import-Module (Import-PSSession $sfboSession -AllowClobber) -Global | Out-Null
        }
    }
    # SharePoint Online
    if ($SharePoint -or $All365) {
        $SharePointAdminSite = 'https://' + $Tenant + '-admin.sharepoint.com'
        try {
            Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking -ErrorAction Stop
        }
        catch {
            Install-Module -Name Microsoft.Online.SharePoint.PowerShell -force -AllowClobber
        }
        if (-not $MFA) {
            try {
                Connect-SPOService -Url $SharePointAdminSite -credential $Credential -ErrorAction stop
                Write-Host "You have successfully connected to SharePoint" -foregroundcolor "magenta" -backgroundcolor "white"
            }
            catch {
                $_
                Write-Warning "Unable to Connect to SharePoint Online."
            }
        }
        else {
            try {
                Connect-SPOService -Url $SharePointAdminSite -ErrorAction stop
                Write-Host "You have successfully connected to SharePoint" -foregroundcolor "magenta" -backgroundcolor "white"
            }
            catch {
                Write-Warning "Unable to Connect to SharePoint Online."
                Write-Warning "verify the tenant name: $Tenant is correct"
                Write-Warning "This was the URL attempted: https:`/`/$Tenant`-admin.sharepoint.com"
            }
        }
    }
    # Azure AD
    If ($AzureAD -or $AzureADver2 -or $All365) {
        if (-not $MFA) {
            If (-not ($null = Get-Module -Name 'AzureAD', 'AzureADPreview' -ListAvailable)) {
                Install-Module -Name AzureAD -Scope CurrentUser -Force -AllowClobber
            }
            try {
                $null = Get-AzureADTenantDetail -ErrorAction Stop
            }
            catch {
                try {
                    $AzureADSplat = @{
                        Credential  = $Credential
                        ErrorAction = 'Stop'
                    }
                    if ($GCCHIGH) {
                        $AzureADSplat['AzureEnvironmentName'] = 'AzureUSGovernment'
                    }
                    Connect-AzureAD @AzureADSplat
                    Write-Host "You have successfully connected to AzureADver2" -foregroundcolor "magenta" -backgroundcolor "white"
                }
                catch {
                    if ($error[0]) {
                        Connect-Cloud $Tenant -DeleteCreds
                        Write-Warning "There was an issue with your credentials"
                        Write-Warning "Please run the same command you just ran and try again"
                        Break
                    }
                    else {
                        $_
                        Write-Warning "There was an error Connecting to Azure Ad - Ensure the module is installed"
                        Write-Warning "Download PowerShell 5 or PowerShellGet"
                        Write-Warning "https://msdn.microsoft.com/en-us/powershell/wmf/5.1/install-configure"
                        Break
                    }
                }
            }
        }
        else {
            If (-not ($null = Get-Module -Name AzureAD -ListAvailable)) {
                Install-Module -Name AzureAD -Scope CurrentUser -Force -AllowClobber
            }
            try {
                $null = Get-AzureADTenantDetail -ErrorAction Stop
            }
            catch {
                try {
                    $AzureADSplat = @{
                        Credential  = $Credential
                        ErrorAction = 'Stop'
                    }
                    if ($GCCHIGH) {
                        $AzureADSplat['AzureEnvironmentName'] = 'AzureUSGovernment'
                    }
                    Connect-AzureAD @AzureADSplat
                    Write-Host "You have successfully connected to AzureADver2" -foregroundcolor "magenta" -backgroundcolor "white"
                }
                catch {
                    if ($error[0]) {
                        Connect-Cloud $Tenant -DeleteCreds
                        Write-Warning "There was as issue with your credentials"
                        Write-Warning "Please run the same command you just ran and try again"
                        Break
                    }
                    else {
                        $error[0]
                        Write-Warning "There was an error Connecting to Azure Ad - Ensure the module is installed"
                        Write-Warning "Download PowerShell 5 or PowerShellGet"
                        Write-Warning "https://msdn.microsoft.com/en-us/powershell/wmf/5.1/install-configure"
                        Break
                    }
                }
            }
        }
    }
    if ($Teams) {
        Connect-CloudModuleImport -Teams
        $TeamsSplat = @{
            Credential = $Credential
        }
        if ($GCCHIGH) {
            $TeamsSplat['TeamsEnvironmentName'] = 'TeamsGCCH'
        }
        Connect-MicrosoftTeams @TeamsSplat
    }
    if ($EXO2 -or $ExchangeOnline -or $Compliance) {
        $Script:RestartConsole = $null
        Connect-CloudModuleImport -EXO2
        if ($RestartConsole) { return }
        $Splat = @{ }
        if ($GCCHIGH) { $Splat['ExchangeEnvironmentName'] = 'O365USGovGCCHigh' }
        if (-not $MFA) { $Splat['Credential'] = $Credential }
        else { $Splat['UserPrincipalName'] = $Credential.UserName }
        if ($EXOPrefix) { $Splat['Prefix'] = 'EXO' }
    }
    if ($Exo2 -or $ExchangeOnline) {
        Connect-ExchangeOnline @Splat -ShowBanner:$false
        Write-Host "You have successfully connected to Exchange Online" -foregroundcolor "magenta" -backgroundcolor "white"
    }
    if ($Az) {
        Connect-CloudModuleImport -Az
        if (Test-Path ($KeyPath + "$($Tenant).cred")) {
            $PwdSecureString = Get-Content ($KeyPath + "$($Tenant).cred") | ConvertTo-SecureString
            $UsernameString = Get-Content ($KeyPath + "$($Tenant).ucred")
            $Credential = [System.Management.Automation.PSCredential]::new($UsernameString, $PwdSecureString)
        }
        else {
            $Credential = Get-Credential -Message "ENTER USERNAME & PASSWORD FOR AZ"
            $Credential.Password | ConvertFrom-SecureString | Out-File ($KeyPath + "$($Tenant).cred") -Force
            $Credential.UserName | Out-File ($KeyPath + "$($Tenant).ucred")
        }
        $AZHash = @{
            Credential = $Credential
        }
        if ($GCCHIGH) {
            $AZHash['Environment'] = 'AzureUSGovernment'
        }
        Connect-AzAccount @AZHash
        Write-Host "You have successfully connected to Az Cmdlets" -foregroundcolor "magenta" -backgroundcolor "white"
    }
    if ($Compliance) {
        Get-PSSession | Remove-PSSession
        Connect-ExchangeOnline -ConnectionUri 'https://ps.compliance.protection.outlook.com/powershell-liveid' @Splat
        Write-Host "You have successfully connected to Security & Compliance Center" -foregroundcolor "magenta" -backgroundcolor "white"
    }
    if ($Intune) {
        Connect-CloudModuleImport -Intune
        if (Test-Path ($KeyPath + "$($Tenant).cred")) {
            $PwdSecureString = Get-Content ($KeyPath + "$($Tenant).cred") | ConvertTo-SecureString
            $UsernameString = Get-Content ($KeyPath + "$($Tenant).ucred")
            $Credential = [System.Management.Automation.PSCredential]::new($UsernameString, $PwdSecureString)
        }
        else {
            $Credential = Get-Credential -Message "ENTER USERNAME & PASSWORD FOR AZ"
            $Credential.Password | ConvertFrom-SecureString | Out-File ($KeyPath + "$($Tenant).cred") -Force
            $Credential.UserName | Out-File ($KeyPath + "$($Tenant).ucred")
        }
        Connect-MSGraph -Credential $Credential
        Write-Host "You have successfully connected to Microsoft's Intune Graph Module" -foregroundcolor "magenta" -backgroundcolor "white"
    }
}