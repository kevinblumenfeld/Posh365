function Compare-TenantEmails {
    <#
    .SYNOPSIS
    Compare PrefixedAddress for two CSVs from two tenants
    Handy for tenant to tenant migrations to find duplicate emails

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
        'DisplayName', 'PrefixedAddress', 'RecipientTypeDetails', 'ExchangeObjectId'
        'TargetDisplayName', 'TargetPrefixedAddress', 'TargetRecipientTypeDetails'
        'TargetExchangeObjectId'
        )
    Compare-TenantEmails -SourceTenant Contoso -TargetTenant Fabrikam -Path C:\Scripts\ | Select-Object $Selects |
    Export-csv C:\Scripts\Contoso\EXO_DuplicateEmails.csv -NoTypeInformation -Encoding UTF8

    .NOTES
    General notes
    #>

    param(
        [Parameter(Mandatory)]
        [string]
        $SourceTenant,

        [Parameter(Mandatory)]
        [string]
        $TargetTenant,

        [Parameter(Mandatory)]
        [string]
        $Path,

        [Parameter()]
        [string]
        $CsvDocument = 'EXO_AllRecipientEmails.csv'
    )
    end {

        $SourceTenantPath = Join-Path $Path $SourceTenant
        $DetailedSourceTenantPath = Join-Path  $SourceTenantPath 'Detailed'

        $TargetTenantPath = Join-Path $Path $TargetTenant
        $DetailedTargetTenantPath = Join-Path  $TargetTenantPath 'Detailed'

        $ExportCSVSplat = @{
            NoTypeInformation = $true
            Encoding          = 'UTF8'
        }

        $SourceAddress = Import-Csv (Join-Path $DetailedSourceTenantPath $CsvDocument)
        $TargetAddress = Import-Csv (Join-Path $DetailedTargetTenantPath $CsvDocument)
        $TargetHash = @{ }
        foreach ($Target in $TargetAddress) {
            $TargetHash[$Target.PrefixedAddress] = @{
                'DisplayName'          = $Target.DisplayName
                'RecipientTypeDetails' = $Target.RecipientTypeDetails
                'Protocol'             = $Target.Protocol
                'Domain'               = $Target.Domain
                'Address'              = $Target.Address
                'Identity'             = $Target.Identity
                'PrimarySmtpAddress'   = $Target.PrimarySmtpAddress
                'ExchangeObjectId'     = $Target.ExchangeObjectId
            }
        }
        foreach ($Source in $SourceAddress) {
            if ($TargetHash.Keys -contains $Source.PrefixedAddress) {
                [PSCustomObject]@{
                    DisplayName                = $Source.DisplayName
                    PrefixedAddress            = $Source.PrefixedAddress
                    RecipientTypeDetails       = $Source.RecipientTypeDetails
                    Address                    = $Source.Address
                    PrimarySmtpAddress         = $Source.PrimarySmtpAddress
                    ExchangeObjectId           = $Source.ExchangeObjectId
                    TargetDisplayName          = $TargetHash.($Source.PrefixedAddress).DisplayName
                    TargetPrefixedAddress      = $Source.PrefixedAddress
                    TargetRecipientTypeDetails = $TargetHash.($Source.PrefixedAddress).RecipientTypeDetails
                    TargetAddress              = $TargetHash.($Source.PrefixedAddress).Address
                    TargetPrimarySmtpAddress   = $TargetHash.($Source.PrefixedAddress).PrimarySmtpAddress
                    TargetExchangeObjectId     = $TargetHash.($Source.PrefixedAddress).ExchangeObjectId
                }
            }
        }
    }
}
