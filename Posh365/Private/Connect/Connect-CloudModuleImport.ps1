function Connect-CloudModuleImport {
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [switch]
        $EXO2,

        [Parameter()]
        [switch]
        $Teams,

        [Parameter()]
        [switch]
        $ExchangeOnline,

        [Parameter()]
        [switch]
        $MSOnline,

        [Parameter()]
        [switch]
        $AzureAD,

        [Parameter()]
        [switch]
        $SharePoint
    )
    end {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        switch ($true) {
            $ExchangeOnline {
                $Modules = @(Get-ChildItem -ErrorAction SilentlyContinue -Path "$($env:LOCALAPPDATA)\Apps\2.0" -Filter "Microsoft.Exchange.Management.ExoPowershellModule.manifest" -Recurse )
                try {
                    $ModuleName = Join-Path $modules[0].Directory.FullName "Microsoft.Exchange.Management.ExoPowershellModule.dll"
                    Import-Module -FullyQualifiedName $ModuleName -Force -WarningAction SilentlyContinue -DisableNameChecking
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
            $EXO2 {
                if (((Get-Module -Name PowerShellGet -ListAvailable).Version.Major | Sort-Object -Descending)[0] -lt 2 ) {
                    try {
                        Install-Module -Name PowerShellGet -Scope CurrentUser -Force -ErrorAction Stop -AllowClobber -SkipPublisherCheck
                        Write-Warning "Exchange Online v.2 module requires PowerShellGet v.2"
                        Write-Warning "PowerShellGet v.2 was just installed"
                        Write-Warning "Please restart this PowerShell console and rerun the same command"
                    }
                    catch {
                        Write-Warning "Unable to install the latest version of PowerShellGet"
                        Write-Warning "and thus unable to install the Exchange Online v.2 module"
                    }
                    $Script:RestartConsole = $true
                    return
                }
                if (-not ($null = Get-Module -Name ExchangeOnlineManagement -ListAvailable)) {
                    $EXOInstall = @{
                        Name          = 'ExchangeOnlineManagement'
                        Scope         = 'CurrentUser'
                        AllowClobber  = $true
                        AcceptLicense = $true
                        Force         = $true
                    }
                    Install-Module @EXOInstall
                }
            }
            $Teams {
                if (-not ($null = Get-Module -Name MicrosoftTeams -ListAvailable)) {
                    Install-Module -Name MicrosoftTeams -Scope CurrentUser -Force -AllowClobber
                }

            }
            $MSOnline {
                if (-not ($null = Get-Module -Name MSOnline -ListAvailable)) {
                    Install-Module -Name MSOnline -Scope CurrentUser -Force -AllowClobber
                }
            }
            $AzureAD {
                if (-not ($null = Get-Module -Name 'AzureAD', 'AzureADPreview' -ListAvailable)) {
                    Install-Module -Name AzureAD -Scope CurrentUser -Force -AllowClobber
                }
            }
            $SharePoint {
                if (-not ($null = Get-Module -Name Microsoft.Online.SharePoint.PowerShell -ListAvailable)) {
                    Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser -Force -AllowClobber
                }
            }
            default { }
        }
    }
}
