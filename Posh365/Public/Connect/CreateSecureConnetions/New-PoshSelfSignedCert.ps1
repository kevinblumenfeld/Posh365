function New-PoshSelfSignedCert {

    Param(

        [Parameter(ParameterSetName = 'ExchangeCBA')]
        [switch]
        $ExchangeCBA,

        [Parameter(Mandatory, ParameterSetName = 'ExchangeCBA')]
        [Parameter(ParameterSetName = 'SSL')]
        [string]
        $Tenant,

        [Parameter(Mandatory, ParameterSetName = 'SSL')]
        [string[]]
        $DnsName,

        [Parameter(ParameterSetName = 'SSL')]
        [Parameter(ParameterSetName = 'ExchangeCBA')]
        [string]
        $CertificateFileName,

        [Parameter(ParameterSetName = 'SSL')]
        [Parameter(ParameterSetName = 'ExchangeCBA')]
        [int]
        $Duration = 1,

        [Parameter(ParameterSetName = 'SSL')]
        [Parameter(ParameterSetName = 'ExchangeCBA')]
        [SecureString]
        $Password
    )

    $PoshCertPath = Join-Path -Path $Env:USERPROFILE -ChildPath '.Posh365/Certificates'

    $ItemSplat = @{
        Type        = 'Directory'
        Force       = $true
        ErrorAction = 'SilentlyContinue'
    }
    if (-not (Test-Path $PoshCertPath)) { $null = New-Item $PoshCertPath @ItemSplat }

    $Path = Join-Path -Path $PoshCertPath -ChildPath $Tenant
    if (-not (Test-Path $Path)) { $null = New-Item $Path @ItemSplat }

    if ($DnsName) {
        $CertNamePrefix = $DnsName[0]
    }
    else {
        $CertNamePrefix = $Tenant
    }
    $CertName = '{0}_{1}' -f $CertNamePrefix, [DateTime]::Now.toString("yyyyMMdd_HHmmss")
    $CerPath = Join-Path -Path $Path -ChildPath "$CertName.cer"
    $PFXPath = Join-Path -Path $Path -ChildPath "$CertName.pfx"

    if (-not $Password) {
        $Password = Read-Host -Prompt "Enter Password to protect private key" -AsSecureString
    }

    # Create certificate
    if ($ExchangeCBA) {
        $CertSplat = @{
            Subject           = 'Exchange Online Secure App Model'
            CertStoreLocation = 'cert:\CurrentUser\My'
            KeySpec           = 'KeyExchange'
            FriendlyName      = 'Exchange Online Certificate Auth'
            NotAfter          = (Get-Date).AddYears($Duration)
        }
    }
    else {
        $CertSplat = @{
            DnsName           = @($DnsName)
            CertStoreLocation = "cert:\LocalMachine\My"
            NotAfter          = (Get-Date).AddYears($Duration)
        }
    }

    $mycert = New-SelfSignedCertificate @CertSplat

    # Export certificate to .pfx file
    $null = $mycert | Export-PfxCertificate -FilePath $PFXPath -Password $(ConvertTo-SecureString -String $Password -AsPlainText -Force)

    # Export certificate to .cer file
    $null = $mycert | Export-Certificate -FilePath $CerPath

    # Invoke-Item $Path

    [PSCustomObject]@{
        Path    = $Path.ToString()
        CerPath = $CerPath.ToString()
        PFXPath = $PFXPath.ToString()
    }
}

