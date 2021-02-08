function New-ExoCBAConnection {
    Param(

        [Parameter(Mandatory)]
        [string]
        $Tenant,

        [Parameter()]
        [string]
        $CertificateFileName,

        [Parameter()]
        [int]
        $Duration = 1,

        [Parameter()]
        [switch]
        $AlsoCreateGraphConnection,

        [Parameter()]
        [switch]
        $GCCHigh
    )

    if ($Tenant -notlike "*.onmicrosoft.*") {
        if ($GCCHigh) {
            $Tenant = "$Tenant.onmicrosoft.us"
        }
        else {
            $Tenant = "$Tenant.onmicrosoft.com"
        }
    }

    $SelfSignedSplat = @{
        ExchangeCBA = $True
        Duration    = $Duration
        Tenant      = $Tenant
    }
    $CertInfo = New-PoshSelfSignedCert @SelfSignedSplat

    # Register Azure AD Application
    $RegisterAppSplat = @{
        Tenant                    = $Tenant
        App                       = 'EXO'
        ReturnAppObject           = $true
        AlsoCreateGraphConnection = $AlsoCreateGraphConnection
    }

    $AppObject = Register-GraphApplication @RegisterAppSplat

    # Connect to AZ
    Connect-CloudModuleImport -Az
    Get-AzContext | Remove-AzContext -Force

    if ($GCCHIGH) {
        $AZHash['Environment'] = 'AzureUSGovernment'
    }
    else {
        $AZHash = @{ }
    }
    $null = Connect-AzAccount @AZHash

    Write-Host "Sleeping 20 seconds. . . " -ForegroundColor Yellow
    Start-Sleep -Seconds 20

    # Upload certificate to application by ApplicationId
    $cer = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $cer.Import($CertInfo.CerPath)
    $binCert = $cer.GetRawCertData()
    $credValue = [System.Convert]::ToBase64String($binCert)

    $UploadSplat = @{
        ApplicationId = $AppObject.TenantClientID
        CertValue     = $credValue
        StartDate     = $cer.NotBefore
        EndDate       = $cer.NotAfter
    }
    $null = New-AzADAppCredential @UploadSplat

    $ServicePrincipal = Get-AzureADServicePrincipal -Filter "AppId eq '$($AppObject.TenantClientID)'"
    $role = Get-AzureADDirectoryRole -Filter "DisplayName eq 'Exchange Administrator'"
    Add-AzureADDirectoryRoleMember -ObjectId $role.ObjectId -RefObjectId $ServicePrincipal.ObjectId

    Write-Host "Connect-ExchangeOnline " -ForegroundColor Yellow -NoNewline
    Write-Host "-AppId " -ForegroundColor White -NoNewline
    Write-Host "$($AppObject.TenantClientID) " -ForegroundColor Green -NoNewline
    Write-Host "-CertificateThumbprint " -ForegroundColor White -NoNewline
    Write-Host "$($Cer.Thumbprint) " -ForegroundColor Green -NoNewline
    Write-Host "-Organization " -ForegroundColor White -NoNewline
    Write-Host "$Tenant" -ForegroundColor Green

    $RootPath = $env:USERPROFILE + "\ps\"
    $KeyPath = $Rootpath + "creds\"

    if (-not (Test-Path $KeyPath)) {
        $null = New-Item -ItemType Directory -Path $KeyPath -ErrorAction STOP
    }
    $EXOCBAPath = (Join-Path $KeyPath "$($Tenant.split('.')[0]).EXOCBA.xml")
    if (Test-Path $EXOCBAPath) {
        $YorN = Read-Host "Connect-Cloud already has a connection. Overwrite?"
        if ($YorN -eq 'N') {
            return
        }
    }

    $InitialDomain = ((Get-AzureADDomain).where{ $_.IsInitial }).Name
    @{
        AppId                 = $AppObject.TenantClientID
        CertificateThumbprint = $Cer.Thumbprint
        Organization          = $InitialDomain
    } | Export-Clixml $EXOCBAPath

    Write-Host "Or use. . . `r`n" -ForegroundColor Cyan
    Write-Host "Connect-Cloud " -ForegroundColor Yellow -NoNewline
    Write-Host "-Tenant " -ForegroundColor White -NoNewline
    Write-Host "$($Tenant.split('.')[0]) " -ForegroundColor Green -NoNewline
    Write-Host "-EXOCBA " -ForegroundColor White -NoNewline

}
