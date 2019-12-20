function Get-ExchangeAddressBookPolicy {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER ABP
    Address Book Policy

    .EXAMPLE
    Get-AddressBookPolicy | Get-ExchangeAddressBookPolicy

    .EXAMPLE
    Get-AddressBookPolicy | Get-ExchangeAddressBookPolicy | Export-Csv .\OABs.csv -notypeinformation

    .EXAMPLE
    Get-AddressBookPolicy -identity "Contoso Address Book Policy" | Get-ExchangeAddressBookPolicy

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        $ABPList
    )
    begin {

    }
    process {
        foreach ($ABP in $ABPList) {
            $Policy = New-Object -TypeName PSObject -Property @{
                Name               = $ABP.Name
                AddressLists       = @($ABP.AddressLists) -ne '' -join '|'
                GlobalAddressList  = $ABP.GlobalAddressList
                OfflineAddressBook = $ABP.OfflineAddressBook
                RoomList           = $ABP.RoomList
                Identity           = $ABP.Identity
                Guid               = $ABP.Guid
                ExchangeVersion    = $ABP.ExchangeVersion
            }
            $Policy | Select-Object @(
                'Name', 'AddressLists', 'GlobalAddressList', 'OfflineAddressBook'
                'RoomList', 'Identity', 'Guid', 'ExchangeVersion'
            )
        }
    }
    end {

    }
}
