function Test-ExchangeOnlineDomain {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainData
    )
    $isOffice365Tenant = "No"

    $msoidRecord = $DomainData.MSOID | Where-Object { $_.NameHost -like '*clientconfig.microsoftonline*' } -ErrorAction SilentlyContinue
    if ($msoidRecord) { $isOffice365Tenant = 'Possibly' }

    $txtVerificationRecord = $DomainData.TXT | Where-Object { $_.Strings -like 'MS=ms*' } -ErrorAction SilentlyContinue
    if ($txtVerificationRecord) { $isOffice365Tenant = 'Possibly' }

    $mdmRecord = $DomainData.ENTERPRISEREGISTRATION | Where-Object { $_.NameHost -eq 'enterpriseregistration.windows.net ' } -ErrorAction SilentlyContinue
    if ($mdmRecord) { $isOffice365Tenant = 'Likely' }

    $autoDiscoverRecord = $DomainData.AUTODISCOVER | Where-Object { $_.NameHost -eq 'autodiscover.outlook.com' } -ErrorAction SilentlyContinue
    if ($autoDiscoverRecord) { $isOffice365Tenant = 'Yes' }

    $spfRecord = $DomainData.TXT | Where-Object { $_.Strings -like '*spf.protection.outlook.com*' } -ErrorAction SilentlyContinue
    if ($spfRecord) { $isOffice365Tenant = 'Yes' }

    $mxRecords = $DomainData.MX | Where-Object { ($_.NameExchange -like '*mail.protection.outlook.com*') -or ($_.NameExchange -like '*eo.outlook.com') } -ErrorAction SilentlyContinue
    if ($mxRecords) { $isOffice365Tenant = 'Yes' }

    $isOffice365Tenant
}
