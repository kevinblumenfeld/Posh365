function Get-ExchangeGlobalAddressList {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER GAL
    Global Address List

    .EXAMPLE
    Get-GlobalAddressList | Get-ExchangeGlobalAddressList

    .EXAMPLE
    Get-GlobalAddressList | Get-ExchangeGlobalAddressList | Export-Csv .\GALS.csv -notypeinformation

    .EXAMPLE
    Get-GlobalAddressList -identity "Contoso GAL" | Get-ExchangeGlobalAddressList

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        $GALList
    )
    begin {

    }
    process {
        foreach ($GAL in $GALList) {
            $GlobalList = New-Object -TypeName PSObject -Property @{
                Name                         = $GAL.Name
                IsDefaultGlobalAddressList   = $GAL.IsDefaultGlobalAddressList
                IncludedRecipients           = $GAL.IncludedRecipients
                RecipientFilterType          = $GAL.RecipientFilterType
                RecipientFilterApplied       = $GAL.RecipientFilterApplied
                RecipientFilter              = $GAL.RecipientFilter
                LastUpdatedRecipientFilter   = $GAL.LastUpdatedRecipientFilter
                ConditionalCustomAttribute1  = @($GAL.ConditionalCustomAttribute1) -ne '' -join '|'
                ConditionalCustomAttribute2  = @($GAL.ConditionalCustomAttribute2) -ne '' -join '|'
                ConditionalCustomAttribute3  = @($GAL.ConditionalCustomAttribute3) -ne '' -join '|'
                ConditionalCustomAttribute4  = @($GAL.ConditionalCustomAttribute4) -ne '' -join '|'
                ConditionalCustomAttribute5  = @($GAL.ConditionalCustomAttribute5) -ne '' -join '|'
                ConditionalCustomAttribute6  = @($GAL.ConditionalCustomAttribute6) -ne '' -join '|'
                ConditionalCustomAttribute7  = @($GAL.ConditionalCustomAttribute7) -ne '' -join '|'
                ConditionalCustomAttribute8  = @($GAL.ConditionalCustomAttribute8) -ne '' -join '|'
                ConditionalCustomAttribute9  = @($GAL.ConditionalCustomAttribute9) -ne '' -join '|'
                ConditionalCustomAttribute10 = @($GAL.ConditionalCustomAttribute10) -ne '' -join '|'
                ConditionalCustomAttribute11 = @($GAL.ConditionalCustomAttribute11) -ne '' -join '|'
                ConditionalCustomAttribute12 = @($GAL.ConditionalCustomAttribute12) -ne '' -join '|'
                ConditionalCustomAttribute13 = @($GAL.ConditionalCustomAttribute13) -ne '' -join '|'
                ConditionalCustomAttribute14 = @($GAL.ConditionalCustomAttribute14) -ne '' -join '|'
                ConditionalCustomAttribute15 = @($GAL.ConditionalCustomAttribute15) -ne '' -join '|'
                ConditionalCompany           = @($GAL.ConditionalCompany) -ne '' -join '|'
                ConditionalDepartment        = @($GAL.ConditionalDepartment) -ne '' -join '|'
                ConditionalStateOrProvince   = @($GAL.ConditionalStateOrProvince) -ne '' -join '|'
                Identity                     = $GAL.Identity
                Container                    = $GAL.Container
                RecipientContainer           = $GAL.RecipientContainer
                LdapRecipientFilter          = $GAL.LdapRecipientFilter
                Guid                         = $GAL.Guid
            }
            $GlobalList | Select-Object @(
                'Name', 'IsDefaultGlobalAddressList', 'IncludedRecipients', 'RecipientFilterType'
                'RecipientFilterApplied', 'RecipientFilter', 'LastUpdatedRecipientFilter'
                'ConditionalCustomAttribute1', 'ConditionalCustomAttribute2', 'ConditionalCustomAttribute3'
                'ConditionalCustomAttribute4', 'ConditionalCustomAttribute5', 'ConditionalCustomAttribute6'
                'ConditionalCustomAttribute7', 'ConditionalCustomAttribute8', 'ConditionalCustomAttribute9'
                'ConditionalCustomAttribute10', 'ConditionalCustomAttribute11', 'ConditionalCustomAttribute12'
                'ConditionalCustomAttribute13', 'ConditionalCustomAttribute14', 'ConditionalCustomAttribute15'
                'ConditionalCompany', 'ConditionalDepartment', 'ConditionalStateOrProvince', 'Container'
                'RecipientContainer', 'LdapRecipientFilter'
            )
        }
    }
    end {

    }
}
