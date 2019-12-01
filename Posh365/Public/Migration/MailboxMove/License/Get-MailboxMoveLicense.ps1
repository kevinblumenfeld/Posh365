function Get-MailboxMoveLicense {
    <#
    .SYNOPSIS
    Reports on a user or users Office 365 enabled Sku
    Either All, All Licensed, SearchString or SharePoint can be used for input
    By default, results are displayed in Out-GridView, unless -ExportToExcel switch is used
    Excel is saved as UserSkus.xlsx to desktop

    .DESCRIPTION
    Reports on a user or users Office 365 enabled Sku
    Either All, All Licensed, SearchString or SharePoint can be used for input

    .PARAMETER SharePointURL
    SharePoint url ex. https://fabrikam.sharepoint.com/sites/Contoso

    .PARAMETER ExcelFile
    Excel file found in "Shared Documents" of SharePoint site specified in SharePointURL
    ex. "Batches.xlsx"

    .PARAMETER All
    All AzureAd Users and their licence(s) or lack thereof

    .PARAMETER AllLicensedOnly
    All licensed AzureAD Users

    .PARAMETER SearchString
    Search by keyword for certain AzureAD Users

    .PARAMETER OnePerLine
    Output one license per line. For example:
    User1 License1
    User1 License1
    User2 License2
    User3 License1

    .PARAMETER ExportToExcel
    Export Results to a xlsx file on the desktop named UserSkus.xlsx
    If a file is already named this on the desktop it will be overwritten with the new data

    .EXAMPLE
    Get-MailboxMoveLicense

    .EXAMPLE
    Get-MailboxMoveLicense -All -ExportToExcel

    .EXAMPLE
    Get-MailboxMoveLicense -All -OnePerLine

    .EXAMPLE
    Get-MailboxMoveLicense -All -OnePerLine -ExportToExcel

    .EXAMPLE
    Get-MailboxMoveLicense -AllLicensedOnly

    .EXAMPLE
    Get-MailboxMoveLicense -AllLicensedOnly -ExportToExcel

    .EXAMPLE
    Get-MailboxMoveLicense -AllLicensedOnly -OnePerLine

    .EXAMPLE
    Get-MailboxMoveLicense -AllLicensedOnly -OnePerLine -ExportToExcel

    .EXAMPLE
    Get-MailboxMoveLicense -SearchString Mike

    .EXAMPLE
    Get-MailboxMoveLicense -SearchString Mike -ExportToExcel

    .EXAMPLE
    Get-MailboxMoveLicense -SearchString Mike -OnePerLine

    .EXAMPLE
    Get-MailboxMoveLicense -SearchString Mike -OnePerLine -ExportToExcel

    .NOTES
    Connect with:

    Connect-Cloud Contoso -EXO2 -AzureADver2

    or

    Connect-CloudMFA Contoso -EXO2 -AzureAD

    #>
    [CmdletBinding(DefaultParameterSetName = "PlaceHolder")]
    param (
        [Parameter(Mandatory, ParameterSetName = 'SharePoint')]
        [ValidateNotNullOrEmpty()]
        [string]
        $SharePointURL,

        [Parameter(Mandatory, ParameterSetName = 'SharePoint')]
        [ValidateNotNullOrEmpty()]
        [string]
        $ExcelFile,

        [Parameter(Mandatory, ParameterSetName = 'All')]
        [ValidateNotNullOrEmpty()]
        [switch]
        $All,

        [Parameter(Mandatory, ParameterSetName = 'AllLicensedOnly')]
        [ValidateNotNullOrEmpty()]
        [switch]
        $AllLicensedOnly,

        [Parameter(ParameterSetName = 'SearchString')]
        [string]
        $SearchString,

        [Parameter(ParameterSetName = 'SharePoint')]
        [Parameter(ParameterSetName = 'SearchString')]
        [Parameter(ParameterSetName = 'All')]
        [Parameter(ParameterSetName = 'AllLicensedOnly')]
        [switch]
        $OnePerLine,

        [Parameter(ParameterSetName = 'SharePoint')]
        [Parameter(ParameterSetName = 'SearchString')]
        [Parameter(ParameterSetName = 'All')]
        [Parameter(ParameterSetName = 'AllLicensedOnly')]
        [switch]
        $ExportToExcel,

        [Parameter(ParameterSetName = 'SharePoint')]
        [Parameter(ParameterSetName = 'SearchString')]
        [Parameter(ParameterSetName = 'All')]
        [Parameter(ParameterSetName = 'AllLicensedOnly')]
        [switch]
        $IncludeRecipientType
    )
    end {
        $Splat = @{
            OnePerLine           = $OnePerLine
            IncludeRecipientType = $IncludeRecipientType
        }
        if ($ExportToExcel) {
            $ExcelSplat = @{
                Path                    = (Join-Path -Path ([Environment]::GetFolderPath("Desktop")) -ChildPath 'UserSkus.xlsx')
                TableStyle              = 'Medium2'
                FreezeTopRowFirstColumn = $true
                AutoSize                = $true
                BoldTopRow              = $false
                ClearSheet              = $true
                ErrorAction             = 'SilentlyContinue'
            }
        }
        switch ($PSCmdlet.ParameterSetName) {
            'SharePoint' {
                $SharePointSplat = @{
                    SharePointURL = $SharePointURL
                    ExcelFile     = $ExcelFile
                    NoBatch       = $true
                }
                $UserChoice = Import-SharePointExcelDecision @SharePointSplat
                if ($UserChoice -ne 'Quit' ) {
                    $Splat.Add('SharePoint', $true)
                    $Splat.Add('UserChoice', $UserChoice)
                    if (-not $ExportToExcel) {
                        Invoke-GetMailboxMoveLicenseUserSku @Splat | Out-GridView -Title "Report of user sku's"
                    }
                    else {
                        Invoke-GetMailboxMoveLicenseUserSku @Splat | Export-Excel @ExcelSplat
                    }
                }
            }
            { $_ -match 'All' } {
                if (-not $AllLicensedOnly) {
                    $UserChoice = Get-AzureADUser -All:$true
                    $Splat.Add('All', $true)
                    $Splat.Add('UserChoice', $UserChoice)
                }
                else {
                    $UserChoice = (Get-AzureADUser -All:$true).Where{ $_.AssignedLicenses }
                    $Splat.Add('AllLicensedOnly', $true)
                    $Splat.Add('UserChoice', $UserChoice)
                }
                if (-not $ExportToExcel) {
                    Invoke-GetMailboxMoveLicenseUserSku @Splat | Out-GridView -Title "Report of user sku's"
                }
                else {
                    Invoke-GetMailboxMoveLicenseUserSku @Splat | Export-Excel @ExcelSplat
                }
            }
            'SearchString' {
                $UserChoice = Get-AzureADUser -SearchString $SearchString
                $Splat.Add('SearchString', $true)
                $Splat.Add('UserChoice', $UserChoice)
                if (-not $ExportToExcel) {
                    Invoke-GetMailboxMoveLicenseUserSku @Splat | Out-GridView -Title "Report of user sku's"
                }
                else {
                    Invoke-GetMailboxMoveLicenseUserSku @Splat | Export-Excel @ExcelSplat
                }
            }
            Default {
                $UserChoice = Get-AzureADUser -All:$true

                $DefaultSplat = @{
                    All                  = $true
                    UserChoice           = $UserChoice
                    IncludeRecipientType = $true
                }

                Invoke-GetMailboxMoveLicenseUserSku @DefaultSplat | Out-GridView -Title "Report of user sku's"
            }
        }
    }
}
