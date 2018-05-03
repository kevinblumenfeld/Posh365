function New-365MsolUser { 
    <#
    .SYNOPSIS
    Add New MsolUsers to Office 365
    #>
    param (
    )

    Import-Csv -Path "C:\Scripts\New_Users.csv" | ForEach-Object {
        New-MsolUser    -DisplayName $_.DisplayName `
                        -FirstName $_.FirstName `
                        -LastName $_.LastName `
                        -UserPrincipalName $_.UserPrincipalName `
                        -UsageLocation $_.UsageLocation `
                        -LicenseAssignment $_.AccountSkuId `
                        -Password $_.Password
    } | Export-Csv -Path "C:\New_Users_RESULTS.csv"
}