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

    All saved credentials are saved in $env:USERPROFILE\ps\creds\  
    Transcript is started and kept in $env:USERPROFILE\ps\<tenantspecified\>  

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
        [parameter(Position = 0, Mandatory = $true)]
        [string] $Tenant,

        [switch] $ExchangeOnline,

        [switch] $MSOnline,

        [switch] $All365,

        [switch] $Azure,    

        [switch] $Skype,

        [switch] $SharePoint,

        [switch] $Compliance,

        [switch] $AzureADver2,               

        [switch] $MFA,

        [switch] $DeleteCreds,

        [switch] $EXOPrefix
    )

    Begin {
        if ($Tenant -match 'onmicrosoft') {
            $Tenant = $Tenant.Split(".")[0]
        }

        $host.ui.RawUI.WindowTitle = "Tenant: $($Tenant.ToUpper())"
        $RootPath = $env:USERPROFILE + "\ps\"
        $KeyPath = $Rootpath + "creds\"
    }
    Process {
        if ($DeleteCreds) {
            Try {
                Remove-Item ($KeyPath + "$($Tenant).cred") -ErrorAction Stop
            }
            Catch {
                Write-Warning "While the attempt to delete credentials failed, this may be normal. Please try to connect again."
            }
            Try {
                Remove-Item ($KeyPath + "$($Tenant).ucred") -ErrorAction Stop
            }
            Catch {
                break
            }
        }
        if (-not (Test-Path ($RootPath + $Tenant + "\logs\"))) {
            New-Item -ItemType Directory -Force -Path ($RootPath + $Tenant + "\logs\")
        }
        Try {
            Start-Transcript -ErrorAction Stop -path ($RootPath + $Tenant + "\logs\" + "transcript-" + ($(get-date -Format _yyyy-MM-dd_HH-mm-ss)) + ".txt") 
        }
        Catch {
            Stop-Transcript 
            Start-Transcript -path ($RootPath + $Tenant + "\logs\" + "transcript-" + ($(get-date -Format _yyyy-MM-dd_HH-mm-ss)) + ".txt")
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
        if ($MFA -and ($ExchangeOnline -or $Compliance)) {
            $modules = @(Get-ChildItem -Path "$($env:LOCALAPPDATA)\Apps\2.0" -Filter "Microsoft.Exchange.Management.ExoPowershellModule.manifest" -Recurse )
            try {
                $moduleName = Join-Path $modules[0].Directory.FullName "Microsoft.Exchange.Management.ExoPowershellModule.dll"
            }
            catch {
                Write-Host "The PowerShell module which supports MFA must be installed."  -foregroundcolor "Black" -backgroundcolor "white"
                Write-Host "We can download the module and install it now."  -foregroundcolor "Black" -backgroundcolor "white"
                Write-Host "Once installed, close the PowerShell window that will pop-up & rerun your command here."  -foregroundcolor "Black" -backgroundcolor "white"
                Write-Host "NOTE: This should only be required once. Should there be any issue with the automatic download, go to https://outlook.office365.com/ecp/ Click Hybrid then click the second Configure button. Save or Run the file depending on your browser. If saved, double click the file to run it." -foregroundcolor "Blue" -backgroundcolor "white"
                Write-Host "Simply choose `"Y`" below then click `"Install`" button when prompted."  -foregroundcolor "Black" -backgroundcolor "white"
                $YesNo = Read-Host "Download Module Now (Y/N)?"
                if ($YesNo -eq "Y") {
                    & "C:\Program Files\Internet Explorer\iexplore.exe" https://cmdletpswmodule.blob.core.windows.net/exopsmodule/Microsoft.Online.CSE.PSModule.Client.application
                    Return
                }
                else {
                    Write-Warning "You must install the PowerShell module to continue."
                    Write-Warning "Either ReRun your command and press `"Y`" or, if you would prefer to install it manually..."
                    Write-Warning "go to the EAC (https://outlook.office365.com/ecp/), then click Hybrid. Click the second Configure button."
                    Write-Warning "Save or run the download depending on your browser prompt. If you saved the file please run it."
                    Return
                }
            }
        }
        if (($ExchangeOnline -or $MSOnline -or $All365 -or $Skype -or $SharePoint -or $Compliance -or $AzureADver2) -and (-not $MFA)) {
            if (Test-Path ($KeyPath + "$($Tenant).cred")) {
                $PwdSecureString = Get-Content ($KeyPath + "$($Tenant).cred") | ConvertTo-SecureString
                $UsernameString = Get-Content ($KeyPath + "$($Tenant).ucred")
                $Credential = Try {
                    New-Object System.Management.Automation.PSCredential -ArgumentList $UsernameString, $PwdSecureString -ErrorAction Stop 
                }
                Catch {
                    if ($_.exception.Message -match '"userName" is not valid. Change the value of the "userName" argument and run the operation again') {
                        Connect-Cloud $Tenant -DeleteCreds
                        Write-Warning "                    Bad Username                                    "
                        Write-Warning "          Please try your last command again...                     "
                        Write-Warning "...you will be prompted to enter your Office 365 credentials again. "
                        Break
                    }
                    Else {
                        $error[0]
                    }
                }
            }
            else {
                $Credential = Get-Credential -Message "ENTER USERNAME & PASSWORD FOR OFFICE 365/AZURE AD"
                if ($Credential.Password) {
                    $Credential.Password | ConvertFrom-SecureString | Out-File ($KeyPath + "$($Tenant).cred") -Force
                }
                else {
                    Connect-Cloud $Tenant -DeleteCreds
                    Write-Warning "                 No Password Present                                "
                    Write-Warning "          Please Try your last command again...                     "
                    Write-Warning "...you will be prompted to enter your Office 365 credentials again. "
                    Break
                }
                $Credential.UserName | Out-File ($KeyPath + "$($Tenant).ucred")
            }
        }
        if ($MSOnline -or $All365) {
            if (-not ($null = Get-Module -Name MSOnline -ListAvailable -ErrorAction Stop)) {
                Install-Module -Name MSOnline -Scope CurrentUser -Force   
            }
            Try {
                $null = Get-MsolAccountSku -ErrorAction Stop
            }
            Catch {
                Try {
                    Connect-MsolService -Credential $Credential -ErrorAction Stop
                    Write-Host "You have successfully connected to MSONLINE" -foregroundcolor "magenta" -backgroundcolor "white"
                }
                Catch {
                    if ($_.exception.Message -match "password") {
                        Connect-Cloud $Tenant -DeleteCreds
                        Write-Warning "           Bad Username or Password.                                "
                        Write-Warning "          Please Try your last command again...                     "
                        Write-Warning "...you will be prompted to enter your Office 365 credentials again. "
                        Break
                    
                    }
                    else {
                        Connect-Cloud $Tenant -DeleteCreds
                        Write-Warning "     There was an error connecting you to MSOnline                  "
                        Write-Warning "          Please Try your last command again...                     "
                        Write-Warning "...you will be prompted to enter your Office 365 credentials again. "
                        Break
                    }
                }
            }
        }
        if ($ExchangeOnline -or $All365) {
            if (-not $MFA) {
                if (-not $EXOPrefix) {
                    # Exchange Online
                    if (-not (Get-Command Get-AcceptedDomain -ErrorAction SilentlyContinue)) {
                        Try {
                            $EXOSession = New-PSSession -Name "EXO" -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell -Credential $Credential -Authentication Basic -AllowRedirection -ErrorAction Stop
                        }
                        Catch {
                            Connect-Cloud $Tenant -DeleteCreds
                            Write-Warning "There was an issue with your credentials"
                            Write-Warning "Please run the same command you just ran and try again"
                            Break
                        }
                        Import-Module (Import-PSSession $EXOSession -AllowClobber -WarningAction SilentlyContinue) -Global | Out-Null
                        Write-Host "You have successfully connected to Exchange Online" -foregroundcolor "magenta" -backgroundcolor "white"
                    }
                }
                else {
                    if (-not (Get-Command Get-CloudAcceptedDomain -ErrorAction SilentlyContinue)) {
                        Try {
                            $EXOSession = New-PSSession -Name "EXO" -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell -Credential $Credential -Authentication Basic -AllowRedirection -ErrorAction Stop
                        }
                        Catch {
                            Connect-Cloud $Tenant -DeleteCreds
                            Write-Warning "There was an issue with your credentials"
                            Write-Warning "Please run the same command you just ran and try again"
                            Break
                        }
                        Import-Module (Import-PSSession $EXOSession -AllowClobber -WarningAction SilentlyContinue -Prefix "Cloud") -Global -Prefix "Cloud" | Out-Null
                        Write-Host "You have successfully connected to Exchange Online With the Prefix Cloud" -foregroundcolor "magenta" -backgroundcolor "white"
                        Write-Host "         For Example: Get-Mailbox is now Get-CloudMailbox               " -foregroundcolor "magenta" -backgroundcolor "white"
                    }
                }
                
            }
            else {
                Import-Module -FullyQualifiedName $moduleName -Force
                Try {
                    Import-Module (Connect-EXOPSSession) -Global
                    Write-Host "You have successfully connected to Exchange Online (MFA)" -foregroundcolor "magenta" -backgroundcolor "white"
                } 
                Catch [System.Management.Automation.CommandNotFoundException] {
                    Write-Warning "Exchange Online MFA module is required or there was an issue connecting"
                    Write-Warning "To download the Exchange Online Remote PowerShell Module for multi-factor authentication,"
                    Write-Warning "in the EAC (https://outlook.office365.com/ecp/), go to Hybrid > Setup and click the appropriate Configure button."
                }
            }
        }
        # Security and Compliance Center
        if ($Compliance -or $All365) {
            if (-not $MFA) {
                $ccSession = New-PSSession -Name "Compliance" -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $credential -Authentication Basic -AllowRedirection
                Import-Module (Import-PSSession $ccSession -AllowClobber) -Global | Out-Null
                Write-Host "You have successfully connected to Compliance" -foregroundcolor "magenta" -backgroundcolor "white"
            }
            else {
                if (-not $ExchangeOnline) {
                    Import-Module -FullyQualifiedName $moduleName -Force
                }
                Try {
                    Import-Module (Connect-IPPSSession) -Global
                    Write-Host "You have successfully connected to the Security & Compliance Center (MFA)" -foregroundcolor "magenta" -backgroundcolor "white"
                } 
                Catch [System.Management.Automation.CommandNotFoundException] {
                    Write-Warning "Exchange Online MFA module is required or there was an issue connecting"
                    Write-Warning "To download the Exchange Online Remote PowerShell Module for multi-factor authentication,"
                    Write-Warning "in the EAC (https://outlook.office365.com/ecp/), go to Hybrid > Setup and click the appropriate Configure button."
                }
            }
        }
        # Skype Online
        if ($Skype -or $All365) {
            if (-not $MFA) {
                Try {
                    $sfboSession = New-CsOnlineSession -ErrorAction Stop -Credential $Credential -OverrideAdminDomain "$Tenant.onmicrosoft.com"
                    Write-Host "You have successfully connected to Skype" -foregroundcolor "magenta" -backgroundcolor "white"
                }
                Catch [System.Management.Automation.CommandNotFoundException] {
                    Write-Warning "Skype for Business Online Module not found.  Please download and install it from here:"
                    Write-Warning "https://www.microsoft.com/en-us/download/details.aspx?id=39366"
                }
                Catch {
                    $_
                }
                Import-Module (Import-PSSession $sfboSession -AllowClobber) -Global | Out-Null
            }
            else {
                Try {
                    $sfboSession = New-CsOnlineSession -UserName $Credential.UserName -OverrideAdminDomain "$Tenant.onmicrosoft.com" -ErrorAction Stop
                    Write-Host "You have successfully connected to Skype" -foregroundcolor "magenta" -backgroundcolor "white"
                }
                Catch [System.Management.Automation.CommandNotFoundException] {
                    Write-Warning "Skype for Business Online Module not found.  Please download and install it from here:"
                    Write-Warning "https://www.microsoft.com/en-us/download/details.aspx?id=39366"
                }
                Catch {
                    $_
                }
                Import-Module (Import-PSSession $sfboSession -AllowClobber) -Global | Out-Null
            }
        }
        # SharePoint Online
        if ($SharePoint -or $All365) {
            $SharePointAdminSite = 'https://' + $Tenant + '-admin.sharepoint.com'
            Try {
                Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking -ErrorAction Stop
            }
            Catch {
                Install-Module -Name Microsoft.Online.SharePoint.PowerShell -force
            }
            if (-not $MFA) {
                Try {
                    Connect-SPOService -Url $SharePointAdminSite -credential $Credential -ErrorAction stop
                    Write-Host "You have successfully connected to SharePoint" -foregroundcolor "magenta" -backgroundcolor "white"
                }
                Catch {
                    $_
                    Write-Warning "Unable to Connect to SharePoint Online."
                }
            }
            else {
                Try {
                    Connect-SPOService -Url $SharePointAdminSite -ErrorAction stop
                    Write-Host "You have successfully connected to SharePoint" -foregroundcolor "magenta" -backgroundcolor "white"
                }
                Catch {
                    Write-Warning "Unable to Connect to SharePoint Online."
                    Write-Warning "verify the tenant name: $Tenant is correct"
                    Write-Warning "This was the URL attempted: https:`/`/$Tenant`-admin.sharepoint.com"
                }
            }
        }
        # Azure
        if ($Azure) {
            Get-LAAzureConnected
        }
        # Azure AD
        If ($AzureADver2 -or $All365) {
            if (-not $MFA) {  
                If (-not ($null = Get-Module -Name AzureAD -ListAvailable)) {
                    Install-Module -Name AzureAD -Scope CurrentUser -Force
                }
                Try {
                    $null = Get-AzureADTenantDetail -ErrorAction Stop
                }
                Catch {
                    Try {
                        Connect-AzureAD -Credential $Credential -ErrorAction Stop
                        Write-Host "You have successfully connected to AzureADver2" -foregroundcolor "magenta" -backgroundcolor "white"
                    }
                    Catch {
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
                    Install-Module -Name AzureAD -Scope CurrentUser -Force
                }
                Try {
                    $null = Get-AzureADTenantDetail -ErrorAction Stop
                }
                Catch {
                    Try {
                        Connect-AzureAD -Credential $Credential -ErrorAction Stop
                        Write-Host "You have successfully connected to AzureADver2" -foregroundcolor "magenta" -backgroundcolor "white"
                    }
                    Catch {
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
    }
    End {
    } 
}
function Get-LAAzureConnected {
    if (-not ($null = Get-Module -Name AzureRM -ListAvailable)) {
        Install-Module -Name AzureRM -Scope CurrentUser -force
    }
    Try {
        $null = Get-AzureRmTenant -ErrorAction Stop
    }
    Catch {
        if (-not $MFA) {
            $json = Get-ChildItem -Recurse -Include '*@*.json' -Path $KeyPath
            if ($json) {
                Write-Host "   Select the Azure username and Click `"OK`" in lower right-hand corner" -foregroundcolor "magenta" -backgroundcolor "white"
                Write-Host "   Otherwise, if this is the first time using this Azure username click `"Cancel`"" -foregroundcolor "magenta" -backgroundcolor "white"
                $json = $json | select name | Out-GridView -PassThru -Title "Select Azure username or click Cancel to use another"
            }
            if (-not ($json)) {
                Try {
                    $azLogin = Login-AzureRmAccount -ErrorAction Stop
                }
                Catch [System.Management.Automation.CommandNotFoundException] {
                    Write-Warning "Download and install PowerShell 5.1 or PowerShellGet so the AzureRM module can be automatically installed"
                    Write-Warning "https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps?view=azurermps-4.2.0#how-to-get-powershellget"
                    Write-Warning "or download the MSI installer and install from here: https://github.com/Azure/azure-powershell/releases"
                    Break
                }
                Save-AzureRmContext -Path ($KeyPath + ($azLogin.Context.Account.Id) + ".json")
                Import-AzureRmContext -Path ($KeyPath + ($azLogin.Context.Account.Id) + ".json")
            }
            else {
                Import-AzureRmContext -Path ($KeyPath + $json.name)
            }
            Write-Host "Select Subscription and Click `"OK`" in lower right-hand corner" -foregroundcolor "magenta" -backgroundcolor "white"
            $subscription = Get-AzureRmSubscription | Out-GridView -PassThru -Title "Choose Azure Subscription"| Select id
            Try {
                Select-AzureRmSubscription -SubscriptionId $subscription.id -ErrorAction Stop
                Write-Host "You have successfully connected to Azure" -foregroundcolor "magenta" -backgroundcolor "white"
            }
            Catch {
                Write-Warning "Azure credentials are invalid or expired. Authenticate again please."
                if ($json.name) {
                    Remove-Item ($KeyPath + $json.name)
                }
                Get-LAAzureConnected
            }
        }
        else {
            Try {
                Login-AzureRmAccount -ErrorAction Stop
            }
            Catch [System.Management.Automation.CommandNotFoundException] {
                Write-Warning "Download and install PowerShell 5.1 or PowerShellGet so the AzureRM module can be automatically installed"
                Write-Warning "https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps?view=azurermps-4.2.0#how-to-get-powershellget"
                Write-Warning "or download the MSI installer and install from here: https://github.com/Azure/azure-powershell/releases"
                Break
            }
            Write-Host "   Select Subscription and Click `"OK`" in lower right-hand corner" -foregroundcolor "magenta" -backgroundcolor "white"
            $subscription = Get-AzureRmSubscription | Out-GridView -PassThru -Title "Choose Azure Subscription" | Select id
            Try {
                Select-AzureRmSubscription -SubscriptionId $subscription.id -ErrorAction Stop
                Write-Host "You have successfully connected to Azure" -foregroundcolor "magenta" -backgroundcolor "white"
            }
            Catch {
                Write-Warning "There was an error selecting your subscription ID"
            }
        }
    }
}