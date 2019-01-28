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

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $false)]
        [Microsoft.Exchange.Data.Directory.Management.GlobalAddressList] $GAL
    )
    Begin {

    }
    Process {
        foreach ($CurGAL in $GAL) {
            $GlobalList = New-Object -TypeName PSObject -Property @{
                Name                         = $CurGAL.Name
                IsDefaultGlobalAddressList   = $CurGAL.IsDefaultGlobalAddressList
                IncludedRecipients           = $CurGAL.IncludedRecipients
                RecipientFilterType          = $CurGAL.RecipientFilterType
                RecipientFilterApplied       = $CurGAL.RecipientFilterApplied
                RecipientFilter              = $CurGAL.RecipientFilter
                LastUpdatedRecipientFilter   = $CurGAL.LastUpdatedRecipientFilter
                ConditionalCustomAttribute1  = ($CurGAL | Where {$_.ConditionalCustomAttribute1 -ne $null}) -join '|'
                ConditionalCustomAttribute2  = ($CurGAL | Where {$_.ConditionalCustomAttribute2 -ne $null}) -join '|'
                ConditionalCustomAttribute3  = ($CurGAL | Where {$_.ConditionalCustomAttribute3 -ne $null}) -join '|'
                ConditionalCustomAttribute4  = ($CurGAL | Where {$_.ConditionalCustomAttribute4 -ne $null}) -join '|'
                ConditionalCustomAttribute5  = ($CurGAL | Where {$_.ConditionalCustomAttribute5 -ne $null}) -join '|'
                ConditionalCustomAttribute6  = ($CurGAL | Where {$_.ConditionalCustomAttribute6 -ne $null}) -join '|'
                ConditionalCustomAttribute7  = ($CurGAL | Where {$_.ConditionalCustomAttribute7 -ne $null}) -join '|'
                ConditionalCustomAttribute8  = ($CurGAL | Where {$_.ConditionalCustomAttribute8 -ne $null}) -join '|'
                ConditionalCustomAttribute9  = ($CurGAL | Where {$_.ConditionalCustomAttribute9 -ne $null}) -join '|'
                ConditionalCustomAttribute10 = ($CurGAL | Where {$_.ConditionalCustomAttribute10 -ne $null}) -join '|'
                ConditionalCustomAttribute11 = ($CurGAL | Where {$_.ConditionalCustomAttribute11 -ne $null}) -join '|'
                ConditionalCustomAttribute12 = ($CurGAL | Where {$_.ConditionalCustomAttribute12 -ne $null}) -join '|'
                ConditionalCustomAttribute13 = ($CurGAL | Where {$_.ConditionalCustomAttribute13 -ne $null}) -join '|'
                ConditionalCustomAttribute14 = ($CurGAL | Where {$_.ConditionalCustomAttribute14 -ne $null}) -join '|'
                ConditionalCustomAttribute15 = ($CurGAL | Where {$_.ConditionalCustomAttribute15 -ne $null}) -join '|'
                ConditionalCompany           = ($CurGAL | Where {$_.ConditionalCompany -ne $null}) -join '|'
                ConditionalDepartment        = ($CurGAL | Where {$_.ConditionalDepartment -ne $null}) -join '|'
                ConditionalStateOrProvince   = ($CurGAL | Where {$_.ConditionalStateOrProvince -ne $null}) -join '|'
                Identity                     = $CurGAL.Identity
                Container                    = $CurGAL.Container
                RecipientContainer           = $CurGAL.RecipientContainer
                LdapRecipientFilter          = $CurGAL.LdapRecipientFilter
                Guid                         = $CurGAL.Guid
            }
            $GlobalList | Select 'DisplayName', 'IsDefaultGlobalAddressList', 'IncludedRecipients', 'RecipientFilterType', 'RecipientFilterApplied', 'RecipientFilter', 'LastUpdatedRecipientFilter', 'ConditionalCustomAttribute1', 'ConditionalCustomAttribute2', 'ConditionalCustomAttribute3', 'ConditionalCustomAttribute4', 'ConditionalCustomAttribute5', 'ConditionalCustomAttribute6', 'ConditionalCustomAttribute7', 'ConditionalCustomAttribute8', 'ConditionalCustomAttribute9', 'ConditionalCustomAttribute10', 'ConditionalCustomAttribute11', 'ConditionalCustomAttribute12', 'ConditionalCustomAttribute13', 'ConditionalCustomAttribute14', 'ConditionalCustomAttribute15', 'ConditionalCompany', 'ConditionalDepartment', 'ConditionalStateOrProvince', 'Containter', 'RecipientContainer', 'LdapRecipientFilter'
        }
    }
    End {

    }
}