function New-PoshSelfSignedCert {

    Param(

        [Parameter(Mandatory)]
        [string[]]
        $DnsName,

        [Parameter()]
        [string]
        $CertificateFileName,

        [Parameter()]
        [int]
        $Duration = 1,

        [Parameter()]
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

    $CertName = '{0}_{1}' -f $DnsName[0], [DateTime]::Now.toString("yyyyMMdd_HHmmss")
    $CerPath = Join-Path -Path $Path -ChildPath "$CertName.cer"
    $PFXPath = Join-Path -Path $Path -ChildPath "$CertName.pfx"

    if (-not $Password) {
        $Password = Read-Host -Prompt "Enter Password to protect private key" -AsSecureString
    }

    # Create certificate
    $mycert = New-SelfSignedCertificate -DnsName $DnsName[0] -CertStoreLocation "cert:\LocalMachine\My" -NotAfter (Get-Date).AddYears($Duration) -KeySpec KeyExchange

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

