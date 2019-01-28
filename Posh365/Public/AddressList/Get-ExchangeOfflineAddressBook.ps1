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

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $false)]
        [Microsoft.Exchange.Data.Directory.SystemConfiguration.OfflineAddressBook] $OAB
    )
    Begin {

    }
    Process {
        foreach ($CurOAB in $OAB) {
            $ListName = $CurOAB.AddressLists | Select -ExpandProperty Name
            $OfflineAddressBook = New-Object -TypeName PSObject -Property @{
                Name            = $CurOAB.Name
                IsDefault       = $CurOAB.IsDefault
                AddressLists    = ($ListName | Where {$_ -ne $null}) -join '|'
                Identity        = $CurOAB.Identity
                Guid            = $CurOAB.Guid
                ExchangeVersion = $CurOAB.ExchangeVersion
            }
            $OfflineAddressBook | Select 'Name', 'IsDefault', 'AddressLists', 'Identity', 'Guid', 'ExchangeVersion'
        }
    }
    End {

    }
}