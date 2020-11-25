function Register-GraphApplication {
    <#
    .SYNOPSIS
    Register Apps with preset permissions for quick access to graph endpoints

    .DESCRIPTION
    Register Apps with preset permissions for quick access to graph endpoints
    Use those permissions with the connection script, Connect-PoshGraph
    Please check the Azure AD app that this app creates to understand the permissions you have prior to running any commands.

    Make sure you that clearly understand and inspect any script before you run them!!!
    I am not responsible for any data in your tenant.  Please test, test and test so more.

    If you want to add or remove permissions you can find your app here:
    https://aad.portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RegisteredApps

    Please seee examples!

    .PARAMETER Tenant
    Use this to uniquely identify the tenant and permissions.
    You will use this to connect to graph with "Connect-PoshGraph"

    Please see examples!

    .PARAMETER App
    Currently just Intune and Teams to choose from, but more to follow.

    Note: The name of the app in Azure AD will be named Intune + the date/time it was added (but you won't need this information to connect)

    .PARAMETER AddDelegateCredentials
    A GUI will appear, type username and password and click "Export Tenant Credentials"

    .EXAMPLE

    Register-GraphApplication -Tenant Contoso -App Intune

    Connect-PoshGraph -Tenant Contoso

    .EXAMPLE

    Register-GraphApplication -Tenant ContosoIntune -App Intune

    Connect-PoshGraph -Tenant ContosoIntune

    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Tenant,

        [Parameter(Mandatory)]
        [ValidateSet('Intune', 'Teams')]
        $App,

        [Parameter()]
        [switch]
        $AddDelegateCredentials
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
    Write-Host " API permission set. Credentials will be encrypted to $TenantPath. Once complete, connect to Graph with: `r`n" -ForegroundColor Cyan
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

    if ($AddDelegateCredentials -or $App -match 'Teams') {
        Write-Host "A GUI will now open, type your Global Admin Username & Password and click - Export Tenant Credentials -" -ForegroundColor Cyan -BackgroundColor White
        Export-GraphConfig -Tenant $Tenant
    }

    Write-Host ('Tenant configuration encrypted to: {0}' -f $TenantConfig)
}
