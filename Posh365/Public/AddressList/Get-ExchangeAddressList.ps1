function Get-ExchangeAddressList {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER AddressList
    Parameter description

    .EXAMPLE
    Get-AddressList | Get-ExchangeAddressList

    .EXAMPLE
    Get-AddressList | Get-ExchangeAddressList | Export-Csv .\AddressLists.csv -notypeinformation

    .EXAMPLE
    Get-AddressList -identity "Internal Mail Users" | Get-ExchangeAddressList

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $false)]
        [Microsoft.Exchange.Data.Directory.Management.AddressList] $AddressList
    )
    Begin {

    }
    Process {
        foreach ($CurAddressList in $AddressList) {
            $List = New-Object -TypeName PSObject -Property @{
                DisplayName                  = $CurAddressList.DisplayName
                IncludedRecipients           = $CurAddressList.IncludedRecipients
                RecipientFilterType          = $CurAddressList.RecipientFilterType
                RecipientFilterApplied       = $CurAddressList.RecipientFilterApplied
                RecipientFilter              = $CurAddressList.RecipientFilter
                LastUpdatedRecipientFilter   = $CurAddressList.LastUpdatedRecipientFilter
                ConditionalCustomAttribute1  = ($CurAddressList | Where {$_.ConditionalCustomAttribute1 -ne $null}) -join '|'
                ConditionalCustomAttribute2  = ($CurAddressList | Where {$_.ConditionalCustomAttribute2 -ne $null}) -join '|'
                ConditionalCustomAttribute3  = ($CurAddressList | Where {$_.ConditionalCustomAttribute3 -ne $null}) -join '|'
                ConditionalCustomAttribute4  = ($CurAddressList | Where {$_.ConditionalCustomAttribute4 -ne $null}) -join '|'
                ConditionalCustomAttribute5  = ($CurAddressList | Where {$_.ConditionalCustomAttribute5 -ne $null}) -join '|'
                ConditionalCustomAttribute6  = ($CurAddressList | Where {$_.ConditionalCustomAttribute6 -ne $null}) -join '|'
                ConditionalCustomAttribute7  = ($CurAddressList | Where {$_.ConditionalCustomAttribute7 -ne $null}) -join '|'
                ConditionalCustomAttribute8  = ($CurAddressList | Where {$_.ConditionalCustomAttribute8 -ne $null}) -join '|'
                ConditionalCustomAttribute9  = ($CurAddressList | Where {$_.ConditionalCustomAttribute9 -ne $null}) -join '|'
                ConditionalCustomAttribute10 = ($CurAddressList | Where {$_.ConditionalCustomAttribute10 -ne $null}) -join '|'
                ConditionalCustomAttribute11 = ($CurAddressList | Where {$_.ConditionalCustomAttribute11 -ne $null}) -join '|'
                ConditionalCustomAttribute12 = ($CurAddressList | Where {$_.ConditionalCustomAttribute12 -ne $null}) -join '|'
                ConditionalCustomAttribute13 = ($CurAddressList | Where {$_.ConditionalCustomAttribute13 -ne $null}) -join '|'
                ConditionalCustomAttribute14 = ($CurAddressList | Where {$_.ConditionalCustomAttribute14 -ne $null}) -join '|'
                ConditionalCustomAttribute15 = ($CurAddressList | Where {$_.ConditionalCustomAttribute15 -ne $null}) -join '|'
                ConditionalCompany           = ($CurAddressList | Where {$_.ConditionalCompany -ne $null}) -join '|'
                ConditionalDepartment        = ($CurAddressList | Where {$_.ConditionalDepartment -ne $null}) -join '|'
                ConditionalStateOrProvince   = ($CurAddressList | Where {$_.ConditionalStateOrProvince -ne $null}) -join '|'
                Identity                     = $CurAddressList.Identity
                Containter                   = $CurAddressList.Containter
                RecipientContainer           = $CurAddressList.RecipientContainer
                LdapRecipientFilter          = $CurAddressList.LdapRecipientFilter
            }
            $List | Select 'DisplayName', 'IncludedRecipients', 'RecipientFilterType', 'RecipientFilterApplied', 'RecipientFilter', 'LastUpdatedRecipientFilter', 'ConditionalCustomAttribute1', 'ConditionalCustomAttribute2', 'ConditionalCustomAttribute3', 'ConditionalCustomAttribute4', 'ConditionalCustomAttribute5', 'ConditionalCustomAttribute6', 'ConditionalCustomAttribute7', 'ConditionalCustomAttribute8', 'ConditionalCustomAttribute9', 'ConditionalCustomAttribute10', 'ConditionalCustomAttribute11', 'ConditionalCustomAttribute12', 'ConditionalCustomAttribute13', 'ConditionalCustomAttribute14', 'ConditionalCustomAttribute15', 'ConditionalCompany', 'ConditionalDepartment', 'ConditionalStateOrProvince', 'Containter', 'RecipientContainer', 'LdapRecipientFilter'
        }
    }
    End {

    }
}