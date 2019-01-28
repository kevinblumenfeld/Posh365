Function Get-ExchangeListandPolicy {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER ReportPath
    Parameter description

    .EXAMPLE
    Get-ExchangeListandPolicy -ReportPath c:\scripts

    .NOTES
    General notes
    #>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [string] $ReportPath
    )

    New-Item -ItemType Directory -Path (Join-Path $ReportPath "Exchange") -ErrorAction SilentlyContinue
    $ExchangePath = Join-Path $ReportPath "Exchange"

    Write-Verbose "Retrieving Address Lists"
    Get-AddressList | Get-ExchangeAddressList |
        Export-csv (Join-Path $ExchangePath "AddressLists.csv") -NoTypeInformation -Encoding UTF8

    Write-Verbose "Retrieving Global Address Lists"
    Get-GlobalAddressList | Get-ExchangeGlobalAddressList
    Export-csv (Join-Path $ExchangePath "GlobalAddressLists.csv") -NoTypeInformation -Encoding UTF8


    Write-Verbose "Retrieving Offline Address Books"
    Get-OfflineAddressBook | Get-ExchangeOfflineAddressBook |
        Export-csv (Join-Path $ExchangePath "OfflineAddressBooks.csv") -NoTypeInformation -Encoding UTF8


    Write-Verbose "Retrieving Address Book Policies"
    Get-AddressBookPolicy | Get-ExchangeAddressBookPolicy |
        Export-csv (Join-Path $ExchangePath "AddressBookPolicies.csv") -NoTypeInformation -Encoding UTF8
}