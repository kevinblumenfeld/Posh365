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

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $false)]
        [Microsoft.Exchange.Data.Directory.SystemConfiguration.AddressBookMailboxPolicy] $ABP
    )
    Begin {

    }
    Process {
        foreach ($CurABP in $ABP) {
            $ListName = $CurABP.AddressLists | Select -ExpandProperty Name
            $Policy = New-Object -TypeName PSObject -Property @{
                Name               = $CurABP.Name
                AddressLists       = ($ListName | Where {$_ -ne $null}) -join '|'
                GlobalAddressList  = $CurABP.GlobalAddressList
                OfflineAddressBook = $CurABP.OfflineAddressBook
                RoomList           = $CurABP.RoomList
                Identity           = $CurABP.Identity
                Guid               = $CurABP.Guid
                ExchangeVersion    = $CurABP.ExchangeVersion
            }
            $Policy | Select 'Name', 'AddressLists', 'GlobalAddressList', 'OfflineAddressBook', 'RoomList', 'Identity', 'Guid', 'ExchangeVersion'
        }
    }
    End {

    }
}