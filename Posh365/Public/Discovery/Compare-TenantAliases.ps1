function Compare-TenantAliases {
    <#
    .SYNOPSIS
    Compare alias from two CSVs from two tenants
    Handy for tenant to tenant migrations to find duplicate aliases

    .DESCRIPTION
    Long description

    .PARAMETER SourceTenant
    Parameter description

    .PARAMETER TargetTenant
    Parameter description

    .PARAMETER Path
    Parameter description

    .PARAMETER CsvDocument
    Parameter description

    .EXAMPLE
    $Selects = @(
        'DisplayName', 'Alias', 'PrefixedAddress', 'RecipientTypeDetails', 'ExchangeObjectId'
        'TargetDisplayName', 'TargetPrefixedAddress', 'TargetRecipientTypeDetails'
        'TargetExchangeObjectId'
        )
    Compare-TenantAliases -SourceTenantPath c:\scripts\contoso\ -TargetTenantPath c:\scripts\fabrikam\ | Select-Object $Selects |
    Export-csv C:\Scripts\Contoso\EXO_DuplicateEmails.csv -NoTypeInformation -Encoding UTF8

    .NOTES
    General notes
    #>

    param(
        [Parameter(Mandatory)]
        [string]
        $SourceTenantPath,

        [Parameter(Mandatory)]
        [string]
        $TargetTenantPath,

        [Parameter()]
        [string]
        $CsvDocument = '365_AllEmails.csv'
    )
    end {
        $SourceAddress = Import-Csv (Join-Path $SourceTenantPath $CsvDocument)
        $TargetAddress = Import-Csv (Join-Path $TargetTenantPath $CsvDocument)
        $TargetHash = @{ }
        # Fix this match?
        foreach ($Target in $TargetAddress.where{ $_.Domain -match 'onmicrosoft.com' }) {
            if ($TargetHash.Keys -notcontains ($Target.Address -split '@')[0]) {
                $TargetHash[($Target.Address -split '@')[0]] = @{
                    'DisplayName'          = $Target.DisplayName
                    'RecipientTypeDetails' = $Target.RecipientTypeDetails
                    'Protocol'             = $Target.Protocol
                    'Domain'               = $Target.Domain
                    'Address'              = $Target.Address
                    'Identity'             = $Target.Identity
                    'PrimarySmtpAddress'   = $Target.PrimarySmtpAddress
                    'PrefixedAddress'      = $Target.PrefixedAddress
                    'ExchangeObjectId'     = $Target.ExchangeObjectId
                }
            }
        }
        $AlreadyAdded = [System.Collections.Generic.HashSet[string]]::new()
        foreach ($Source in $SourceAddress.where{ $_.Domain -match 'onmicrosoft.com' }) {
            $SourceAndTargetID = '{0}{1}' -f $Source.ExchangeObjectId, $TargetHash.(($Source.Address -split '@')[0]).ExchangeObjectId
            if ($TargetHash.Keys -contains ($Source.Address -split '@')[0] -and -not $AlreadyAdded.Contains($SourceAndTargetID)) {
                $null = $AlreadyAdded.Add($SourceAndTargetID)
                [PSCustomObject]@{
                    DisplayName                = $Source.DisplayName
                    Alias                      = ($Source.Address -split '@')[0]
                    PrefixedAddress            = $Source.PrefixedAddress
                    RecipientTypeDetails       = $Source.RecipientTypeDetails
                    Address                    = $Source.Address
                    PrimarySmtpAddress         = $Source.PrimarySmtpAddress
                    ExchangeObjectId           = $Source.ExchangeObjectId
                    TargetDisplayName          = $TargetHash.(($Source.Address -split '@')[0]).DisplayName
                    TargetPrefixedAddress      = $TargetHash.(($Source.Address -split '@')[0]).PrefixedAddress
                    TargetRecipientTypeDetails = $TargetHash.(($Source.Address -split '@')[0]).RecipientTypeDetails
                    TargetAddress              = $TargetHash.(($Source.Address -split '@')[0]).Address
                    TargetPrimarySmtpAddress   = $TargetHash.(($Source.Address -split '@')[0]).PrimarySmtpAddress
                    TargetExchangeObjectId     = $TargetHash.(($Source.Address -split '@')[0]).ExchangeObjectId
                }
            }
        }
    }
}
