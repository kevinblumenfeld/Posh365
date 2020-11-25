function Register-GraphApplication {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Tenant,

        [Parameter(Mandatory)]
        [ValidateSet('Intune', 'Teams')]
        $App
    )

    $PoshPath = Join-Path -Path $Env:USERPROFILE -ChildPath '.Posh365/Credentials/Graph'
    $ItemSplat = @{
        Type        = 'Directory'
        Force       = $true
        ErrorAction = 'SilentlyContinue'
    }
    if (-not (Test-Path $PoshPath)) { New-Item $PoshPath @ItemSplat }
    $TenantPath = Join-Path -Path $PoshPath -ChildPath $Tenant

    if (Test-Path $TenantPath) {
        Write-Host "$TenantPath is already in use" -ForegroundColor Yellow -NoNewline
        $UsePath = Read-Host ". Type 'YES' to overwrite"
        if ($UsePath -ne 'YES') {
            Write-Host "Please rerun your command and choose another name to represent your connection" -ForegroundColor Green
            Write-Host "Perhaps, try appending the the app's function to the company name" -ForegroundColor Green
            Write-Host "For example, Contoso-Intune" -ForegroundColor Green
            return
        }
    }
    if (-not (Test-Path $TenantPath)) { New-Item $TenantPath @ItemSplat }


    Write-Host "`r`nWe will create an Azure AD Application with the " -ForegroundColor Cyan -NoNewline
    Write-Host "$App" -ForegroundColor Green -NoNewLine
    Write-Host " API permission set. Credentials will be encrypted to $TenantPath. Once complete, connect to Graph with: " -ForegroundColor Cyan -NoNewline
    Write-Host "Connect-PoshGraph " -ForegroundColor Yellow -NoNewline
    Write-Host "-Tenant " -ForegroundColor White -NoNewline
    Write-Host "$Tenant`r`n`r`n" -ForegroundColor Green



    If (-not ($null = Get-Module -Name 'AzureAD', 'AzureADPreview' -ListAvailable)) {
        Write-Host "Installing AzureAD module" -ForegroundColor Cyan
        Install-Module -Name AzureAD -Scope CurrentUser -Force -AllowClobber
        Import-Module -Name AzureAD -force
    }
    If (-not ($null = Get-Command -Name 'Import-TemplateApp')) {
        Write-Host "Installing CloneApp module" -ForegroundColor Cyan
        Install-Module -Name CloneApp -Scope CurrentUser -Force -AllowClobber
        Import-Module -Name CloneApp -force
    }

    Write-Host "Disconnecting any possible connections to Azure AD" -ForegroundColor White
    try { $null = Disconnect-AzureAD -ErrorAction Stop } catch { }
    try {
        Write-Host "Please enter your Azure AD Credentials to login to Azure AD . . . " -ForegroundColor White
        $AzureAD = Connect-AzureAD -ErrorAction Stop
        Write-Host "Connected to Azure AD!" -ForegroundColor Cyan
        Write-Host "Tenant: " -ForegroundColor Green -NoNewline
        Write-Host "$($AzureAD.TenantId)" -ForegroundColor White
        Write-Host "Account: " -ForegroundColor Green -NoNewline
        Write-Host "$($AzureAD.Account)" -ForegroundColor White
    }
    catch {
        Write-Host "Not connected to Azure AD. " -ForegroundColor Yellow -NoNewline
        Write-Host "Please run the same command again and connect to Azure AD." -ForegroundColor Cyan
        return
    }

    $Params = @{
        Name                = $App
        ConsentAction       = 'Both'
        GithubUsername      = 'KevinBlumenfeld'
        GistFilename        = '{0}.xml' -f $App
        SecretDurationYears = 10
        Owner               = ($AzureAD.Account).toString()
    }
    $NewApp = Import-TemplateApp @Params
    $PoshPath = Join-Path -Path $Env:USERPROFILE -ChildPath '.Posh365/Credentials/Graph'

    $ConfigObject = [PSCustomObject]@{
        TenantClientID = $NewApp.ApplicationId
        TenantTenantID = $NewApp.TenantId
        TenantSecret   = $NewApp.Secret | ConvertTo-SecureString -AsPlainText -Force
    }
    $TenantConfig = Join-Path -Path $TenantPath -ChildPath ('{0}Config.xml' -f $Tenant)
    [PSCustomObject]@{
        Cred     = [PSCredential]::new($ConfigObject.TenantTenantID, $ConfigObject.TenantSecret)
        ClientId = $ConfigObject.TenantClientID
    } | Export-Clixml -Path $TenantConfig

    Write-Host ('Tenant configuration encrypted to: {0}' -f $TenantConfig)
}
