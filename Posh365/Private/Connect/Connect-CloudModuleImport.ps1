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
        $Az,

        [Parameter()]
        [switch]
        $AzureAD,

        [Parameter()]
        [switch]
        $Intune,

        [Parameter()]
        [switch]
        $SharePoint
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    switch ($true) {
        { $Az } {
            if (-not ($null = Get-Module Az.Accounts -ListAvailable)) {
                try {
                    Write-Host "Installing AZ.Resources Module..." -ForegroundColor White
                    Install-Module -Name Az.Resources -Scope CurrentUser -Force -ErrorAction Stop
                    Write-Host "Succesfully installed AZ.Resources Module..." -ForegroundColor Green
                }
                catch {
                    Write-Warning "Unable to install the latest version of Az.Resources. Error: $($Exception.Message)"
                }
            }
        }
        { $EXO2 -or $ExchangeOnline } {
            if (((Get-Module PowerShellGet -ListAvailable).Version.Major | Sort-Object -Descending | Select-Object -First 1) -lt 2) {
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
            if ($null = (((Get-Module ExchangeOnlineManagement -ListAvailable).Version.Major | Sort-Object -Descending) | Select-Object -First 1) -lt 1) {
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
            if (-not ($null = Get-Module -Name Microsoft.Graph.Intune -ListAvailable)) {
                Install-Module -Name Microsoft.Graph.Intune -Scope CurrentUser -Force -AllowClobber
            }
        }
        $Intune {
            if (-not ($null = Get-Module -Name Microsoft.Online.SharePoint.PowerShell -ListAvailable)) {
                Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser -Force -AllowClobber
            }
        }
        default { }
    }
}
