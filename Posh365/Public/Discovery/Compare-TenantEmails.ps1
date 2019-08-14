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
    Compare-TenantEmails -SourceTenantPath c:\scripts\contoso\ -TargetTenantPath c:\scripts\fabrikam\ | Select-Object $Selects |
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
