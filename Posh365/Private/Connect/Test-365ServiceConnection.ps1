function Test-365ServiceConnection {
    [CmdletBinding()]
    Param
    (
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
        $Compliance
    )
    end {
        $EA = $ErrorActionPreference
        $ErrorActionPreference = 'SilentlyContinue'
        if ($ExchangeOnline) {
            $tenantEX = (Get-AcceptedDomain).where( { $_.Default }).domainname.split('.')[0]
            $TenantName = $tenantEX
        }
        if ($AzureAD) {
            $tenantAZ = ((Get-AzureADTenantDetail).verifiedDomains | Where-Object { $_.initial -eq "$true" }).name.split(".")[0]
            $TenantName = $tenantAZ
        }
        if ($MSOnline) {
            $tenantMS = (Get-MsolDomain).where( { $_.IsInitial }).name.split('.')[0]
            $TenantName = $tenantMS
        }
        if ($Compliance) {
            $tenantCO = (Get-Group | Select-Object -First 1).organizationalunit.replace('.onmicrosoft.com/Configuration', '').split('/')[2]
            $TenantName = $tenantCO
        }
        $TenantName
    }
}
