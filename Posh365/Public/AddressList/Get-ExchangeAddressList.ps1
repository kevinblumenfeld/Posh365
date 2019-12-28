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

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        $AddressList
    )
    begin {

    }
    process {
        foreach ($AList in $AddressList) {
            $List = New-Object -TypeName PSObject -Property @{
                DisplayName                  = $AList.DisplayName
                IncludedRecipients           = $AList.IncludedRecipients
                RecipientFilterType          = $AList.RecipientFilterType
                RecipientFilterApplied       = $AList.RecipientFilterApplied
                RecipientFilter              = $AList.RecipientFilter
                LastUpdatedRecipientFilter   = $AList.LastUpdatedRecipientFilter
                ConditionalCustomAttribute1  = @($AList.ConditionalCustomAttribute1) -ne '' -join '|'
                ConditionalCustomAttribute2  = @($AList.ConditionalCustomAttribute2) -ne '' -join '|'
                ConditionalCustomAttribute3  = @($AList.ConditionalCustomAttribute3) -ne '' -join '|'
                ConditionalCustomAttribute4  = @($AList.ConditionalCustomAttribute4) -ne '' -join '|'
                ConditionalCustomAttribute5  = @($AList.ConditionalCustomAttribute5) -ne '' -join '|'
                ConditionalCustomAttribute6  = @($AList.ConditionalCustomAttribute6) -ne '' -join '|'
                ConditionalCustomAttribute7  = @($AList.ConditionalCustomAttribute7) -ne '' -join '|'
                ConditionalCustomAttribute8  = @($AList.ConditionalCustomAttribute8) -ne '' -join '|'
                ConditionalCustomAttribute9  = @($AList.ConditionalCustomAttribute9) -ne '' -join '|'
                ConditionalCustomAttribute10 = @($AList.ConditionalCustomAttribute10) -ne '' -join '|'
                ConditionalCustomAttribute11 = @($AList.ConditionalCustomAttribute11) -ne '' -join '|'
                ConditionalCustomAttribute12 = @($AList.ConditionalCustomAttribute12) -ne '' -join '|'
                ConditionalCustomAttribute13 = @($AList.ConditionalCustomAttribute13) -ne '' -join '|'
                ConditionalCustomAttribute14 = @($AList.ConditionalCustomAttribute14) -ne '' -join '|'
                ConditionalCustomAttribute15 = @($AList.ConditionalCustomAttribute15) -ne '' -join '|'
                ConditionalCompany           = @($AList.ConditionalCompany) -ne '' -join '|'
                ConditionalDepartment        = @($AList.ConditionalDepartment) -ne '' -join '|'
                ConditionalStateOrProvince   = @($AList.ConditionalStateOrProvince) -ne '' -join '|'
                Identity                     = $AList.Identity
                Container                    = $AList.Container
                RecipientContainer           = $AList.RecipientContainer
                LdapRecipientFilter          = $AList.LdapRecipientFilter
            }
            $List | Select-Object @(
                'DisplayName', 'IncludedRecipients', 'RecipientFilterType', 'RecipientFilterApplied'
                'RecipientFilter', 'LastUpdatedRecipientFilter', 'ConditionalCustomAttribute1'
                'ConditionalCustomAttribute2', 'ConditionalCustomAttribute3', 'ConditionalCustomAttribute4'
                'ConditionalCustomAttribute5', 'ConditionalCustomAttribute6', 'ConditionalCustomAttribute7'
                'ConditionalCustomAttribute8', 'ConditionalCustomAttribute9', 'ConditionalCustomAttribute10'
                'ConditionalCustomAttribute11', 'ConditionalCustomAttribute12', 'ConditionalCustomAttribute13'
                'ConditionalCustomAttribute14', 'ConditionalCustomAttribute15', 'ConditionalCompany'
                'ConditionalDepartment', 'ConditionalStateOrProvince', 'Container', 'RecipientContainer'
                'LdapRecipientFilter'
            )
        }
    }
    end {

    }
}
