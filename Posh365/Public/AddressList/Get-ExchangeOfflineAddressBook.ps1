function Get-ExchangeOfflineAddressBook {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER OAB
    Offline Address Book

    .EXAMPLE
    Get-OfflineAddressBook | Get-ExchangeOfflineAddressBook

    .EXAMPLE
    Get-OfflineAddressBook | Get-ExchangeOfflineAddressBook | Export-Csv .\OABs.csv -notypeinformation

    .EXAMPLE
    Get-OfflineAddressBook -identity "Internal Mail Users" | Get-ExchangeOfflineAddressBook

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        $OABList
    )
    begin {

    }
    process {
        foreach ($OAB in $OABList) {
            $OfflineAddressBook = New-Object -TypeName PSObject -Property @{
                Name            = $OAB.Name
                IsDefault       = $OAB.IsDefault
                AddressLists    = @($OAB.AddressLists) -ne '' -join '|'
                Identity        = $OAB.Identity
                Guid            = $OAB.Guid
                ExchangeVersion = $OAB.ExchangeVersion
            }
            $OfflineAddressBook | Select-Object 'Name', 'IsDefault', 'AddressLists', 'Identity', 'Guid', 'ExchangeVersion'
        }
    }
    end {

    }
}
