Function Get-DiscoveryInfo {
    <#
    .SYNOPSIS
    On-Premises Active Directory discovery

    .EXAMPLE

    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (

    )

    try {
        Import-Module activedirectory -ErrorAction Stop -Verbose:$false
    }
    catch {
        Write-Host "This module depends on the ActiveDirectory module."
        Write-Host "Please download and install from https://www.microsoft.com/en-us/download/details.aspx?id=45520"
        throw
    }

    do {
        $Answer = Read-Host "Connect to Exchange Server? (Y/N)"
        if ($Answer -eq "Y") {
            $ServerName = Read-Host "Type the name of the Exchange Server and hit enter"
            Connect-Exchange -Server $ServerName
        }
    } until ($Answer -eq 'Y' -or $Answer -eq 'N')


    $Discovery = Join-Path ([Environment]::GetFolderPath("Desktop")) -ChildPath 'Discovery'
    $Detailed = Join-Path $Discovery -ChildPath 'Detailed'
    $CSV = Join-Path $Discovery -ChildPath 'CSV'
    New-Item -ItemType Directory -Path $Discovery -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $Detailed -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $CSV -ErrorAction SilentlyContinue

    $CsvSplat = @{
        NoTypeInformation = $true
        Encoding          = 'UTF8'
    }

    Write-Verbose "Retrieving all Active Directory Users"
    Get-ADUser -Filter * -Properties * | Select-Object * | Export-Clixml -Path (Join-Path -Path $Detailed -ChildPath 'ADUsers.xml')
    Get-ActiveDirectoryUser -DetailedReport | Export-Csv @CSVSplat -Path (Join-Path -Path $Detailed -ChildPath 'ADUsers.csv')

    Write-Verbose "Retrieving Active Directory Replication"
    Get-ADReplication | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'ADReplication.csv')

    Write-Verbose "Retrieving all Exchange Receive Connectors"
    Get-ExchangeReceiveConnector | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'ReceiveConn.csv')

    Write-Verbose "Retrieving all Exchange Send Connectors"
    Get-ExchangeSendConnector | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'SendConn.csv')

    Write-Verbose "Retrieving Address Lists"
    Get-AddressList | Get-ExchangeAddressList | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'AddressLists.csv')

    Write-Verbose "Retrieving Global Address Lists"
    Get-GlobalAddressList | Get-ExchangeGlobalAddressList | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'GlobalAddressLists.csv')

    Write-Verbose "Retrieving Offline Address Books"
    Get-OfflineAddressBook | Get-ExchangeOfflineAddressBook | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'OfflineAddressBook.csv')

    Write-Verbose "Retrieving Address Book Policies"
    Get-AddressBookPolicy | Get-ExchangeAddressBookPolicy | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'AddressBookPolicies.csv')

    Write-Verbose "Retrieving all Exchange Distribution Groups"
    Get-DistributionGroup | Select-Object * | Export-Clixml -Path (Join-Path -Path $Detailed -ChildPath 'ExchangeDistributionGroups.xml')
    Get-ExchangeDistributionGroup -DetailedReport | Export-Csv @CSVSplat -Path (Join-Path -Path $Detailed -ChildPath 'ExchangeDistributionGroups.csv')

}
