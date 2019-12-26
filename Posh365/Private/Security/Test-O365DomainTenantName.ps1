function Test-O365DomainTenantName {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainData
    )
    $isOffice365Tenant = Test-ExchangeOnlineDomain $DomainData

    if ($isOffice365Tenant -eq 'No') { return "N/A" }

    $lowestPreferenceMX = $DomainData.MX | Where-Object { $_.NameExchange -ne $null } -ErrorAction SilentlyContinue |
    Sort-Object -Property Preference | Select-Object -First 1 -ErrorAction SilentlyContinue

    $nameExchange = $lowestPreferenceMX | Select-Object -ExpandProperty NameExchange -ErrorAction SilentlyContinue

    if ($nameExchange -eq $null) { return "Undetermined" }

    if ($nameExchange.Contains('mail.protection.outlook.com')) {
        $record = $nameExchange | Where-Object { $_ -like '*.mail.protection.outlook.com' } | Select-Object -First 1
        if ($record) { $record.Replace('.mail.protection.outlook.com', '') }
    }
    else { return "Undetermined" }
}
