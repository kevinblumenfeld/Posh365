function Get-MailboxSyncLicenseCount {
    <#
    .SYNOPSIS
    Get a quick look at how many Office 365 skus are available and assigned

    .DESCRIPTION
    Get a quick look at how many Office 365 skus are available and assigned

    .EXAMPLE
    Get-MailboxSyncLicenseCount

    .NOTES
    Negative numbers represent when a sku is assigned/consumed but there are none available.
    Usually after a trial or if a company decided not to renew that sku
    #>

    [CmdletBinding()]
    param (

    )
    end {
        'placeholder' | Set-CloudLicense -DisplayTenantsSkusAndOptionsFriendlyNames -ErrorAction SilentlyContinue
    }
}
