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
        switch ($true) {
            $ExchangeOnline {
                $tenantEX = (Get-AcceptedDomain).where( { $_.Default }).domainname.split('.')[0]
                if ($tenantEX) { $tenant = $tenantEX } else { $ConnectHash.Add('EXO2', $true) }
            }
            $AzureAD {
                $tenantAZ = ((Get-AzureADTenantDetail -ErrorAction SilentlyContinue).verifiedDomains | Where-Object { $_.initial -eq "$true" }).name.split(".")[0]
                if ($tenantAZ) { $tenant = $tenantAZ } else { $ConnectHash.Add('AzureAD', $true) }

            }
            $MSOnline {
                $tenantMS = (Get-MsolDomain -ErrorAction SilentlyContinue).where( { $_.IsInitial }).name.split('.')[0]
                if ($tenantMS) { $tenant = $tenantMS } else { $ConnectHash.Add('MSOnline', $true) }

            }
            $Compliance {
                $tenantCO = (Get-Group | Select-Object -First 1).organizationalunit.replace('.onmicrosoft.com/Configuration', '').split('/')[2]
                if ($tenantCO) { $tenant = $tenantCO } else { $ConnectHash.Add('Compliance', $true) }
            }
            Default { $tenant }
        }
        $ErrorActionPreference = $EA
    }
}
