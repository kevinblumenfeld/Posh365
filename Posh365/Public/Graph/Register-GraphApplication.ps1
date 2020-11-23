function Register-GraphApplication {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Tenant,

        [Parameter(Mandatory)]
        [ValidateSet('Intune', 'Teams')]
        $PermissionSet
    )

    Write-Host "`r`nWe will create an Azure AD Application with the " -ForegroundColor Cyan -NoNewline
    Write-Host "$PermissionSet" -ForegroundColor Green -NoNewLine
    Write-Host " API permission set. Credentials are encrypted locally. Once complete, connect to Graph with: " -ForegroundColor Cyan -NoNewline
    Write-Host "Connect-GraphInteractive " -ForegroundColor Yellow -NoNewline
    Write-Host "-Tenant " -ForegroundColor White -NoNewline
    Write-Host "$Tenant`r`n`r`n" -ForegroundColor Green

    If (-not ($null = Get-Module -Name 'AzureAD', 'AzureADPreview' -ListAvailable)) {
        Write-Host "Installing AzureAD module" -ForegroundColor Cyan
        Install-Module -Name AzureAD -Scope CurrentUser -Force -AllowClobber
        Import-Module -Name AzureAD -force
    }
    If (-not ($null = Get-Module -Name 'CloneApp' -ListAvailable)) {
        Write-Host "Installing CloneApp module" -ForegroundColor Cyan
        Install-Module -Name CloneApp -Scope CurrentUser -Force -AllowClobber
        Import-Module -Name CloneApp -force
    }
    try {
        $null = Get-AzureADTenantDetail -ErrorAction Stop
    }
    catch {
        # try {
        #     Connect-AzureAD -Credential $Credential -ErrorAction 'Stop'
        #     Write-Host "You have successfully connected to AzureADver2" -foregroundcolor Magenta -backgroundcolor White
        # }
        # catch { }
        # Write-Host "First step is to sign you into Azure AD"
        # $Username = Read-Host "Enter username for a Global Adminstrator"
        # $Password = Read-Host "Enter password"

    }
}
