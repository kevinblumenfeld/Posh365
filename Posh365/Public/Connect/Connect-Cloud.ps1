function Connect-Cloud {
    
 
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

        # Delete invalid or unwanted credentials
        if ($DeleteCreds) {
            Remove-Item ($KeyPath + "$($Tenant).cred") 
            Remove-Item ($KeyPath + "$($Tenant).ucred")
        }
        # Create Directory for Transact Logs
        if (!(Test-Path ($RootPath + $Tenant + "\logs\"))) {
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
        if (!(Test-Path $KeyPath)) {
            Try {
                $null = New-Item -ItemType Directory -Path $KeyPath -ErrorAction STOP
            }
            Catch {
                throw $_.Exception.Message
            }           
        }
        if ($ExchangeOnline -or $MSOnline -or $All365 -or $Skype -or $SharePoint -or $Compliance -or $AzureADver2) {
            if (Test-Path ($KeyPath + "$($Tenant).cred")) {
                $PwdSecureString = Get-Content ($KeyPath + "$($Tenant).cred") | ConvertTo-SecureString
                $UsernameString = Get-Content ($KeyPath + "$($Tenant).ucred")
                $Credential = Try {
                    New-Object System.Management.Automation.PSCredential -ArgumentList $UsernameString, $PwdSecureString -ErrorAction Stop 
                }
                Catch {
                    if ($_.exception.Message -match '"userName" is not valid. Change the value of the "userName" argument and run the operation again') {
                        Connect-Cloud $Tenant -DeleteCreds
                        Write-Host "********************************************************************" -foregroundcolor "darkblue" -backgroundcolor "white"
                        Write-Host "                    Bad Username                                    " -foregroundcolor "darkblue" -backgroundcolor "white"
                        Write-Host "          Please try your last command again...                     " -foregroundcolor "darkblue" -backgroundcolor "white"
                        Write-Host "...you will be prompted to enter your Office 365 credentials again. " -foregroundcolor "darkblue" -backgroundcolor "white"
                        Write-Host "********************************************************************" -foregroundcolor "darkblue" -backgroundcolor "white"
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
                    Write-Host "********************************************************************" -foregroundcolor "darkgreen" -backgroundcolor "white"
                    Write-Host "                 No Password Present                                " -foregroundcolor "darkgreen" -backgroundcolor "white"
                    Write-Host "          Please Try your last command again...                     " -foregroundcolor "darkgreen" -backgroundcolor "white"
                    Write-Host "...you will be prompted to enter your Office 365 credentials again. " -foregroundcolor "darkgreen" -backgroundcolor "white"
                    Write-Host "********************************************************************" -foregroundcolor "darkgreen" -backgroundcolor "white"
                    Break
                }
                $Credential.UserName | Out-File ($KeyPath + "$($Tenant).ucred")
            }
        }
        if ($MSOnline -or $All365) {
            # Office 365 Tenant
            Try {
                $null = Get-Command "Get-MsolAccountSku" -ErrorAction Stop
            }
            Catch {
                Install-Module -Name MSOnline -Scope CurrentUser -Force
            }
            Try {
                Connect-MsolService -Credential $Credential -ErrorAction Stop
                Write-Output "*******************************************"
                Write-Output "You have successfully connected to MSONLINE"
                Write-Output "*******************************************"
            }
            Catch {
                if ($_.exception.Message -match "password") {
                    Connect-Cloud $Tenant -DeleteCreds
                    Write-Host "********************************************************************" -foregroundcolor "darkgreen" -backgroundcolor "white"
                    Write-Host "           Bad Username or Password.                                " -foregroundcolor "darkgreen" -backgroundcolor "white"
                    Write-Host "          Please Try your last command again...                     " -foregroundcolor "darkgreen" -backgroundcolor "white"
                    Write-Host "...you will be prompted to enter your Office 365 credentials again. " -foregroundcolor "darkgreen" -backgroundcolor "white"
                    Write-Host "********************************************************************" -foregroundcolor "darkgreen" -backgroundcolor "white"
                    Break
                    
                }
                else {
                    Connect-Cloud $Tenant -DeleteCreds
                    Write-Host "********************************************************************" -foregroundcolor "darkgreen" -backgroundcolor "white"
                    Write-Host "           There was an error connecting you to MSOnline            " -foregroundcolor "darkgreen" -backgroundcolor "white"
                    Write-Host "********************************************************************" -foregroundcolor "darkgreen" -backgroundcolor "white"
                    Break
                }
            }
        }
        if ($ExchangeOnline -or $All365) {
            if (!$MFA) {
                if (!$EXOPrefix) {
                    # Exchange Online
                    if (!(Get-Command Get-AcceptedDomain -ErrorAction SilentlyContinue)) {
                        Try {
                            $EXOSession = New-PSSession -Name "EXO" -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell -Credential $Credential -Authentication Basic -AllowRedirection -ErrorAction Stop
                        }
                        Catch {
                            Connect-Cloud $Tenant -DeleteCreds
                            Write-Output "There was an issue with your credentials"
                            Write-Output "Please run the same command you just ran and try again"
                            Break
                        }
                        Import-Module (Import-PSSession $EXOSession -AllowClobber -WarningAction SilentlyContinue) -Global | Out-Null
                        Write-Output "**************************************************"
                        Write-Output "You have successfully connected to Exchange Online"
                        Write-Output "**************************************************"
                    }
                }
                else {
                    if (!(Get-Command Get-CloudAcceptedDomain -ErrorAction SilentlyContinue)) {
                        Try {
                            $EXOSession = New-PSSession -Name "EXO" -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell -Credential $Credential -Authentication Basic -AllowRedirection -ErrorAction Stop
                        }
                        Catch {
                            Connect-Cloud $Tenant -DeleteCreds
                            Write-Output "There was an issue with your credentials"
                            Write-Output "Please run the same command you just ran and try again"
                            Break
                        }
                        Import-Module (Import-PSSession $EXOSession -AllowClobber -WarningAction SilentlyContinue -Prefix "Cloud") -Global -Prefix "Cloud" | Out-Null
                        Write-Output "************************************************************************"
                        Write-Output "You have successfully connected to Exchange Online With the Prefix Cloud"
                        Write-Output "         For Example: Get-Mailbox is now Get-CloudMailbox               "
                        Write-Output "************************************************************************"
                    }
                }
                
            }
            else {
                Try {
                    Connect-EXOPSSession -UserPrincipalName $Credential.UserName -ErrorAction Stop
                    Write-Output "********************************************************"
                    Write-Output "You have successfully connected to Exchange Online (MFA)"
                    Write-Output "********************************************************"
                } 
                Catch [System.Management.Automation.CommandNotFoundException] {
                    Write-Output "Exchange Online MFA module is required"
                    Write-Output "To download the Exchange Online Remote PowerShell Module for multi-factor authentication,"
                    Write-Output "in the EAC (https://outlook.office365.com/ecp/), go to Hybrid > Setup and click the appropriate Configure button."
                }
            }
        }
        # Security and Compliance Center
        if ($Compliance -or $All365 -and (! $MFA)) {
            $ccSession = New-PSSession -Name "Compliance" -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $credential -Authentication Basic -AllowRedirection
            Import-Module (Import-PSSession $ccSession -AllowClobber) -Global | Out-Null
            Write-Output "*********************************************"
            Write-Output "You have successfully connected to Compliance"
            Write-Output "*********************************************"
        }
        # Skype Online
        if ($Skype -or $All365) {
            if (! $MFA) {
                Try {
                    $sfboSession = New-CsOnlineSession -ErrorAction Stop -Credential $Credential -OverrideAdminDomain "$Tenant.onmicrosoft.com"
                    Write-Output "****************************************"
                    Write-Output "You have successfully connected to Skype"
                    Write-Output "****************************************"
                }
                Catch [System.Management.Automation.CommandNotFoundException] {
                    Write-Output "Skype for Business Online Module not found.  Please download and install it from here:"
                    Write-Output "https://www.microsoft.com/en-us/download/details.aspx?id=39366"
                }
                Catch {
                    $_
                }
                Import-Module (Import-PSSession $sfboSession -AllowClobber) -Global | Out-Null
            }
            else {
                Try {
                    $sfboSession = New-CsOnlineSession -UserName $Credential.UserName -OverrideAdminDomain "$Tenant.onmicrosoft.com" -ErrorAction Stop
                    Write-Output "****************************************"
                    Write-Output "You have successfully connected to Skype"
                    Write-Output "****************************************"
                }
                Catch [System.Management.Automation.CommandNotFoundException] {
                    Write-Output "Skype for Business Online Module not found.  Please download and install it from here:"
                    Write-Output "https://www.microsoft.com/en-us/download/details.aspx?id=39366"
                }
                Catch {
                    $_
                }
            }
        }
        # SharePoint Online
        if ($SharePoint -or $All365) {
            Try {
                Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking -ErrorAction Stop
            }
            Catch {
                Write-Output "Unable to import SharePoint Module"
                Write-Output "Ensure it is installed, Download it from here: https://www.microsoft.com/en-us/download/details.aspx?id=35588"
            }
            if (! $MFA) {
                Try {
                    Connect-SPOService -Url ("https://" + $Tenant + "-admin.sharepoint.com") -credential $Credential -ErrorAction stop
                    Write-Output "*********************************************"
                    Write-Output "You have successfully connected to SharePoint"
                    Write-Output "*********************************************"
                }
                Catch {
                    Write-Host "Unable to Connect to SharePoint Online."
                }
            }
            else {
                Try {
                    Connect-SPOService -Url ("https://" + $Tenant + "-admin.sharepoint.com") -ErrorAction stop
                    Write-Output "*********************************************"
                    Write-Output "You have successfully connected to SharePoint"
                    Write-Output "*********************************************"
                }
                Catch {
                    Write-Host "Unable to Connect to SharePoint Online."
                }
            }
        }
        # Azure
        if ($Azure) {
            Get-LAAzureConnected
        }
        # Azure AD
        If ($AzureADver2 -or $All365) {
            if (! $MFA) {  
                Try {
                    $null = Get-Command "Get-AzureADTenantDetail" -ErrorAction Stop
                }
                Catch {
                    Install-Module AzureAD -scope CurrentUser -force
                }
                Try {
                    Connect-AzureAD -Credential $Credential -ErrorAction Stop
                    Write-Output "**********************************************"
                    Write-Output "You have successfully connected to AzureADver2"
                    Write-Output "**********************************************"
                }
                Catch {
                    if ($error[0]) {
                        Connect-Cloud $Tenant -DeleteCreds
                        Write-Output "There was an issue with your credentials"
                        Write-Output "Please run the same command you just ran and try again"
                        Break
                    }
                    else {
                        $_
                        Write-Output "There was an error Connecting to Azure Ad - Ensure the module is installed"
                        Write-Output "Download PowerShell 5 or PowerShellGet"
                        Write-Output "https://msdn.microsoft.com/en-us/powershell/wmf/5.1/install-configure"
                        Break
                    }
                    
                }
            }
            else {  
                Try {
                    $null = Get-Command "Get-AzureADTenantDetail" -ErrorAction Stop
                }
                Catch {
                    Install-Module AzureAD -scope CurrentUser -force
                }
                Try {
                    Connect-AzureAD -Credential $Credential -ErrorAction Stop
                    Write-Output "**********************************************"
                    Write-Output "You have successfully connected to AzureADver2"
                    Write-Output "**********************************************"
                }
                Catch {
                    if ($error[0]) {
                        Connect-Cloud $Tenant -DeleteCreds
                        Write-Output "There was as issue with your credentials"
                        Write-Output "Please run the same command you just ran and try again"
                        Break
                    }
                    else {
                        $error[0]
                        Write-Output "There was an error Connecting to Azure Ad - Ensure the module is installed"
                        Write-Output "Download PowerShell 5 or PowerShellGet"
                        Write-Output "https://msdn.microsoft.com/en-us/powershell/wmf/5.1/install-configure"
                        Break
                    }
                    
                }
            }
        }
    }
    End {
    } 
}

function Get-LAAzureConnected {
    Try {
        $null = Get-Command "Get-AzureRmTenant" -ErrorAction Stop
    }
    Catch {
        Install-Module -Name AzureRM -Scope CurrentUser -force
    }
    if (! $MFA) {
        $json = Get-ChildItem -Recurse -Include '*@*.json' -Path $KeyPath
        if ($json) {
            Write-Host   "************************************************************************************" -foregroundcolor "magenta" -backgroundcolor "white"
            Write-Host   "************************************************************************************" -foregroundcolor "magenta" -backgroundcolor "white"
            Write-Output "   Select the Azure username and Click `"OK`" in lower right-hand corner"
            Write-Output "   Otherwise, if this is the first time using this Azure username click `"Cancel`""
            Write-Host   "************************************************************************************" -foregroundcolor "magenta" -backgroundcolor "white"
            Write-Host   "************************************************************************************" -foregroundcolor "magenta" -backgroundcolor "white"
            $json = $json | select name | Out-GridView -PassThru -Title "Select Azure username or click Cancel to use another"
        }
        if (!($json)) {
            Try {
                $azLogin = Login-AzureRmAccount -ErrorAction Stop
            }
            Catch [System.Management.Automation.CommandNotFoundException] {
                Write-Output "Download and install PowerShell 5.1 or PowerShellGet so the AzureRM module can be automatically installed"
                Write-Output "https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps?view=azurermps-4.2.0#how-to-get-powershellget"
                Write-Output "or download the MSI installer and install from here: https://github.com/Azure/azure-powershell/releases"
                Break
            }
            Save-AzureRmContext -Path ($KeyPath + ($azLogin.Context.Account.Id) + ".json")
            Import-AzureRmContext -Path ($KeyPath + ($azLogin.Context.Account.Id) + ".json")
        }
        else {
            Import-AzureRmContext -Path ($KeyPath + $json.name)
        }
        Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "white"
        Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "white"
        Write-Output "   Select Subscription and Click `"OK`" in lower right-hand corner"
        Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "white"
        Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "white"
        $subscription = Get-AzureRmSubscription | Out-GridView -PassThru -Title "Choose Azure Subscription"| Select id
        Try {
            Select-AzureRmSubscription -SubscriptionId $subscription.id -ErrorAction Stop
            Write-Output "****************************************"
            Write-Output "You have successfully connected to Azure"
            Write-Output "****************************************"
        }
        Catch {
            Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "white"
            Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "white"
            Write-Output " Azure credentials are invalid or expired. Authenticate again please."
            Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "white"
            Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "white"
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
            Write-Output "Download and install PowerShell 5.1 or PowerShellGet so the AzureRM module can be automatically installed"
            Write-Output "https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps?view=azurermps-4.2.0#how-to-get-powershellget"
            Write-Output "or download the MSI installer and install from here: https://github.com/Azure/azure-powershell/releases"
            Break
        }
        Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "white"
        Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "white"
        Write-Output "   Select Subscription and Click `"OK`" in lower right-hand corner"
        Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "white"
        Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "white"
        $subscription = Get-AzureRmSubscription | Out-GridView -PassThru -Title "Choose Azure Subscription" | Select id
        Try {
            Select-AzureRmSubscription -SubscriptionId $subscription.id -ErrorAction Stop
            Write-Output "****************************************"
            Write-Output "You have successfully connected to Azure"
            Write-Output "****************************************"
        }
        Catch {
            Write-Output "There was an error selecting your subscription ID"
        }
    }
}
