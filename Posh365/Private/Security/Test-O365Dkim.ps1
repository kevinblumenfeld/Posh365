function Test-O365Dkim {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainData
    )
    $isOffice365Tenant = Test-ExchangeOnlineDomain $DomainData

    if ($isOffice365Tenant -eq 'No') { return "N/A" }

    if (($DomainData.O365DKIM.SELECTOR1 -ne $null) -and ($DomainData.O365DKIM.SELECTOR2 -ne $null)) {
        $True
    }
    else {
        $false
    }
}
