function New-CBAExchangeOnlineApp {
    Param(

        [Parameter(Mandatory)]
        [string[]]
        $DnsName,

        [Parameter()]
        [string]
        $ConnectionName,

        [Parameter()]
        [string]
        $CertificateFileName,

        [Parameter()]
        [int]
        $Duration = 1,

        [Parameter()]
        [SecureString]
        $Password,

        [Parameter()]
        [switch]
        $GCCHigh
    )

    # Create a certificate
    if (-not $Password) {
        $Password = Read-Host -Prompt "Enter Password to protect private key" -AsSecureString
    }

    $Splat = @{
        DnsName  = $DnsName
        Duration = $Duration
        Password = $Password
    }
    if ($CertificateFileName) {
        $Splat['CertificateFileName'] = $CertificateFileName
    }
    $CertInfo = New-PoshSelfSignedCert @Splat

    # Register Azure AD Application
    if (-not $ConnectionName) {
        $ConnectionName = $DnsName[0]
    }
    $AppObject = Register-GraphApplication -Tenant $ConnectionName -App 'EXO' -ReturnAppObject
    Get-AzContext | Remove-AzContext -Force

    if ($GCCHIGH) {
        $AZHash['Environment'] = 'AzureUSGovernment'
    }
    else {
        $AZHash = @{ }
    }
    $null = Connect-AzAccount @AZHash

    Write-Host "Sleeping one minute. . . " -ForegroundColor Yellow
    Start-Sleep -Seconds 10

    # Upload certificate to application by ApplicationId
    $cer = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $cer.Import($CertInfo.CerPath)
    $binCert = $cer.GetRawCertData()
    $credValue = [System.Convert]::ToBase64String($binCert)
    New-AzADAppCredential -ApplicationId $AppObject.ApplicationId -CertValue $credValue -StartDate $cer.NotBefore -EndDate $cer.NotAfter

}