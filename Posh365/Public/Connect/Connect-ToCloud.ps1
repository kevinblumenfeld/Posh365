function Connect-ToCloud {
    
 
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param
    (

        [parameter(Position = 0, Mandatory = $true)]
        [string] $Tenant,

        [parameter(Position = 1, Mandatory = $false)]
        [string] $User,
                           
        [Parameter(Mandatory = $false)]
        [switch] $ExchangeOnline,
                              
        [Parameter(Mandatory = $false)]
        [switch] $MSOnline,
                       
        [Parameter(Mandatory = $false)]
        [switch] $All365,
                
        [Parameter(Mandatory = $false)]
        [switch] $Azure,    

        [parameter(Mandatory = $false)]
        [switch] $Skype,
          
        [parameter(Mandatory = $false)]
        [switch] $SharePoint,
         
        [parameter(Mandatory = $false)]
        [switch] $Compliance,

        [parameter(Mandatory = $false)]
        [switch] $AzureADver2,
               
        [Parameter(Mandatory = $false)]
        [switch] $MFA,

        [parameter(Mandatory = $false)]
        [switch] $DeleteCreds
        
    )

    Begin {
        if ($Tenant -match 'onmicrosoft') {
            $Tenant = $Tenant.Split(".")[0]
        }
        if (! $User) {
            $User = "Default"
        }
		
        $host.ui.RawUI.WindowTitle = "Tenant: $($Tenant.ToUpper())"
    }
    Process {

        $RootPath = $env:USERPROFILE + "\ps\"
        $KeyPath = $Rootpath + "creds\"

        # Delete invalid or unwanted credentials
        if ($DeleteCreds) {
            Remove-Item ($KeyPath + "$($Tenant).$($user).cred") 
            Remove-Item ($KeyPath + "$($Tenant).$($user).ucred")
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
            try {
                New-Item -ItemType Directory -Path $KeyPath -ErrorAction STOP | Out-Null
            }
            catch {
                throw $_.Exception.Message
            }           
        }
        if ($ExchangeOnline -or $MSOnline -or $All365 -or $Skype -or $SharePoint -or $Compliance -or $AzureADver2) {
            if (Test-Path ($KeyPath + "$($Tenant).$($user).cred")) {
                $PwdSecureString = Get-Content ($KeyPath + "$($Tenant).$($user).cred") | ConvertTo-SecureString
                $UsernameString = Get-Content ($KeyPath + "$($Tenant).$($user).ucred")
                $Credential = Try {
                    New-Object System.Management.Automation.PSCredential -ArgumentList $UsernameString, $PwdSecureString -ErrorAction Stop 
                }
                Catch {
                    if ($_.exception.Message -match '"userName" is not valid. Change the value of the "userName" argument and run the operation again') {
                        Connect-ToCloud $Tenant -DeleteCreds
                        Write-Host "********************************************************************" -foregroundcolor "darkblue" -backgroundcolor "white"
                        Write-Host "                    Bad Username                                    " -foregroundcolor "darkblue" -backgroundcolor "white"
                        Write-Host "          Please try your last command again...                     " -foregroundcolor "darkblue" -backgroundcolor "white"
                        Write-Host "...you will be prompted to enter your Office 365 credentials again. " -foregroundcolor "darkblue" -backgroundcolor "white"
                        Write-Host "********************************************************************" -foregroundcolor "darkblue" -backgroundcolor "white"
                        Break
                    }
                }
            }
            else {
                $Credential = Get-Credential -Message "ENTER USERNAME & PASSWORD FOR OFFICE 365/AZURE AD"
                if ($Credential.Password) {
                    $Credential.Password | ConvertFrom-SecureString | Out-File ($KeyPath + "$($Tenant).$($user).cred") -Force
                }
                else {
                    Connect-ToCloud $Tenant -DeleteCreds
                    Write-Host "********************************************************************" -foregroundcolor "darkgreen" -backgroundcolor "white"
                    Write-Host "                 No Password Present                                " -foregroundcolor "darkgreen" -backgroundcolor "white"
                    Write-Host "          Please try your last command again...                     " -foregroundcolor "darkgreen" -backgroundcolor "white"
                    Write-Host "...you will be prompted to enter your Office 365 credentials again. " -foregroundcolor "darkgreen" -backgroundcolor "white"
                    Write-Host "********************************************************************" -foregroundcolor "darkgreen" -backgroundcolor "white"
                    Break
                }
                $Credential.UserName | Out-File ($KeyPath + "$($Tenant).$($user).ucred")
            }
        }
        if ($MSOnline -or $All365) {
            # Office 365 Tenant
            Try {
                if (!(Get-Module -ListAvailable MSOnline)) {
                    Install-Module -Name MSOnline -Scope CurrentUser -ErrorAction SilentlyContinue   
                }
                Import-Module MsOnline -ErrorAction Stop
            }
            Catch {
                Write-Output "MSOnline module is required"
                Write-Output "To download the prerequisite and MSOnline module:"
                Write-Output "https://technet.microsoft.com/en-us/library/dn975125.aspx"
            }
            Try {
                Connect-MsolService -Credential $Credential -ErrorAction Stop
                Write-Output "*******************************************"
                Write-Output "You have successfully connected to MSONLINE"
                Write-Output "*******************************************"
                
            }
            Catch {
                if ($_.exception.Message -match "Bad username or password") {
                    Connect-ToCloud $Tenant -DeleteCreds
                    Write-Host "********************************************************************" -foregroundcolor "darkgreen" -backgroundcolor "white"
                    Write-Host "           Bad Username or Password.                                " -foregroundcolor "darkgreen" -backgroundcolor "white"
                    Write-Host "          Please try your last command again...                     " -foregroundcolor "darkgreen" -backgroundcolor "white"
                    Write-Host "...you will be prompted to enter your Office 365 credentials again. " -foregroundcolor "darkgreen" -backgroundcolor "white"
                    Write-Host "********************************************************************" -foregroundcolor "darkgreen" -backgroundcolor "white"
                    Break
                }
            }
        }
        if ($ExchangeOnline -or $All365) {
            if (! $MFA) {
                # Exchange Online
                $EXOSession = New-PSSession -Name "EXO" -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell -Credential $Credential -Authentication Basic -AllowRedirection 
                Import-Module (Import-PSSession $EXOSession -AllowClobber -WarningAction SilentlyContinue) -Global | Out-Null
                Write-Output "**************************************************"
                Write-Output "You have successfully connected to Exchange Online"
                Write-Output "**************************************************"
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
                Connect-SPOService -Url ("https://" + $Tenant + "-admin.sharepoint.com") -credential $Credential
                Write-Output "*********************************************"
                Write-Output "You have successfully connected to SharePoint"
                Write-Output "*********************************************"
            }
            else {
                Connect-SPOService -Url ("https://" + $Tenant + "-admin.sharepoint.com")
                Write-Output "*********************************************"
                Write-Output "You have successfully connected to SharePoint"
                Write-Output "*********************************************"
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
                    if (!(get-module AzureAD -listavailable)) {
                        Install-Module AzureAD -scope CurrentUser -ErrorAction Stop
                    }
                    if (!(Get-AzureADTenantDetail)) {
                        Import-Module -Name AzureAD -MinimumVersion '2.0.0.131' -ErrorAction Stop
                        Connect-AzureAD -Credential $Credential -ErrorAction Stop
                        Write-Output "**********************************************"
                        Write-Output "You have successfully connected to AzureADver2"
                        Write-Output "**********************************************"
                    }
                    else {
                        Write-Output "**********************************************"
                        Write-Output "You have successfully connected to AzureADver2"
                        Write-Output "**********************************************" 
                    }
                        

                }
                Catch {
                    Write-Output "There was an error Connecting to Azure Ad - Ensure the module is installed"
                    Write-Output "Download PowerShell 5 or PowerShellGet"
                    Write-Output "https://msdn.microsoft.com/en-us/powershell/wmf/5.1/install-configure"
                }
                
            }
            else {
                Try {
                    Install-Module -Name AzureAD -MinimumVersion '2.0.0.131' -Scope CurrentUser -ErrorAction Stop
                    Import-Module -Name AzureAD -MinimumVersion '2.0.0.131' -ErrorAction Stop
                    Connect-AzureAD -Credential $Credential -ErrorAction Stop
                    Write-Output "**********************************************"
                    Write-Output "You have successfully connected to AzureADver2"
                    Write-Output "**********************************************"
                }
                Catch {
                    Write-Output "There was an error Connecting to Azure Ad - Ensure the module is installed"
                    Write-Output "Download PowerShell 5 or PowerShellGet"
                    Write-Output "https://msdn.microsoft.com/en-us/powershell/wmf/5.1/install-configure"
                }
            }
        }
    }
    End {
    } 
}

function Get-LAAzureConnected {
    if (!(Get-AzureRmTenant)) {
        Install-Module -Name AzureRM -Scope CurrentUser
    }
    Import-Module -Name AzureRM -MinimumVersion '4.2.1'
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
            catch [System.Management.Automation.CommandNotFoundException] {
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
            Write-Output "   Azure credentials have expired. Authenticate again please."
            Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "white"
            Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "white"
            Remove-Item ($KeyPath + $json.name)
            Get-LAAzureConnected
        }
    }
    else {
        Try {
            Login-AzureRmAccount -ErrorAction Stop
        }
        catch [System.Management.Automation.CommandNotFoundException] {
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
