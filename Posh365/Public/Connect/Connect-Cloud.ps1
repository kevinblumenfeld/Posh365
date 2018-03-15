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
        if ($DeleteCreds) {
            Remove-Item ($KeyPath + "$($Tenant).cred") 
            Remove-Item ($KeyPath + "$($Tenant).ucred")
        }
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
            Try {
                $null = Get-Module -Name MSOnline -ListAvailable -ErrorAction Stop
            }
            Catch {
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
            if (!$MFA) {
                if (!$EXOPrefix) {
                    # Exchange Online
                    if (!(Get-Command Get-AcceptedDomain -ErrorAction SilentlyContinue)) {
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
                    if (!(Get-Command Get-CloudAcceptedDomain -ErrorAction SilentlyContinue)) {
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
                Try {
                    Connect-EXOPSSession -UserPrincipalName $Credential.UserName -ErrorAction Stop
                    Write-Host "You have successfully connected to Exchange Online (MFA)" -foregroundcolor "magenta" -backgroundcolor "white"
                } 
                Catch [System.Management.Automation.CommandNotFoundException] {
                    Write-Warning "Exchange Online MFA module is required"
                    Write-Warning "To download the Exchange Online Remote PowerShell Module for multi-factor authentication,"
                    Write-Warning "in the EAC (https://outlook.office365.com/ecp/), go to Hybrid > Setup and click the appropriate Configure button."
                }
            }
        }
        # Security and Compliance Center
        if ($Compliance -or $All365 -and (! $MFA)) {
            $ccSession = New-PSSession -Name "Compliance" -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $credential -Authentication Basic -AllowRedirection
            Import-Module (Import-PSSession $ccSession -AllowClobber) -Global | Out-Null
            Write-Host "You have successfully connected to Compliance" -foregroundcolor "magenta" -backgroundcolor "white"
        }
        # Skype Online
        if ($Skype -or $All365) {
            if (! $MFA) {
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
            }
        }
        # SharePoint Online
        if ($SharePoint -or $All365) {
            Try {
                Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking -ErrorAction Stop
            }
            Catch {
                Write-Warning "Unable to import SharePoint Module"
                Write-Warning "Ensure it is installed, Download it from here: https://www.microsoft.com/en-us/download/details.aspx?id=35588"
            }
            if (! $MFA) {
                Try {
                    Connect-SPOService -Url ("https://" + $Tenant + "-admin.sharepoint.com") -credential $Credential -ErrorAction stop
                    Write-Host "You have successfully connected to SharePoint" -foregroundcolor "magenta" -backgroundcolor "white"
                }
                Catch {
                    Write-Warning "Unable to Connect to SharePoint Online."
                }
            }
            else {
                Try {
                    Connect-SPOService -Url ("https://" + $Tenant + "-admin.sharepoint.com") -ErrorAction stop
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
            if (! $MFA) {  
                Try {
                    $null = Get-Module -Name AzureAD -ListAvailable -ErrorAction Stop
                }
                Catch {
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
                Try {
                    $null = Get-Module -Name AzureAD -ListAvailable -ErrorAction Stop
                }
                Catch {
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
    Try {
        $null = Get-Module -Name AzureRM -ListAvailable -ErrorAction Stop
    }
    Catch {
        Install-Module -Name AzureRM -Scope CurrentUser -force
    }
    Try {
        $null = Get-AzureRmTenant -ErrorAction Stop
    }
    Catch {
        if (! $MFA) {
            $json = Get-ChildItem -Recurse -Include '*@*.json' -Path $KeyPath
            if ($json) {
                Write-Host "   Select the Azure username and Click `"OK`" in lower right-hand corner" -foregroundcolor "magenta" -backgroundcolor "white"
                Write-Host "   Otherwise, if this is the first time using this Azure username click `"Cancel`"" -foregroundcolor "magenta" -backgroundcolor "white"
                $json = $json | select name | Out-GridView -PassThru -Title "Select Azure username or click Cancel to use another"
            }
            if (!($json)) {
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
