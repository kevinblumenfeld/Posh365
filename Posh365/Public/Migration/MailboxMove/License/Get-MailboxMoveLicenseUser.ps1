function Get-MailboxMoveLicenseUser {
    <#
    .SYNOPSIS
    Reports on a user or users Office 365 enabled licenses
    Either CSV or Excel file from SharePoint can be used
    Out-GridView is used for each user.
    Helpful for a maximum of 10-20 users as each user opens in their own window

    .DESCRIPTION
    Reports on a user or users Office 365 enabled licenses
    Either CSV or Excel file from SharePoint can be used
    Out-GridView is used for each user.
    Helpful for a maximum of 10-20 users as each user opens in their own window

    .PARAMETER SharePointURL
    Sharepoint url ex. https://fabrikam.sharepoint.com/sites/Contoso

    .PARAMETER ExcelFile
    Excel file found in "Shared Documents" of SharePoint site specified in SharePointURL
    ex. "Batches.xlsx"
    Minimum headers required are: BatchName, UserPrincipalName

    .PARAMETER MailboxCSV
    Path to csv of mailboxes. Minimum headers required are: BatchName, UserPrincipalName

    .EXAMPLE
    Get-MailboxMoveLicenseUser -MailboxCSV c:\scripts\batches.csv

    .EXAMPLE
    Get-MailboxMoveLicenseUser -SharePointURL 'https://fabrikam.sharepoint.com/sites/Contoso' -ExcelFile 'Batches.xlsx'

    .NOTES
    General notes
    #>

    [CmdletBinding(DefaultParameterSetName = 'SharePoint')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'SharePoint')]
        [ValidateNotNullOrEmpty()]
        [string]
        $SharePointURL,

        [Parameter(Mandatory, ParameterSetName = 'SharePoint')]
        [ValidateNotNullOrEmpty()]
        [string]
        $ExcelFile,

        [Parameter(Mandatory, ParameterSetName = 'CSV')]
        [ValidateNotNullOrEmpty()]
        [string]
        $MailboxCSV
    )
    end {
        switch ($PSCmdlet.ParameterSetName) {
            'SharePoint' {
                $SharePointSplat = @{
                    SharePointURL = $SharePointURL
                    ExcelFile     = $ExcelFile
                    NoBatch       = $true
                }
                $UserChoice = Import-SharePointExcelDecision @SharePointSplat
            }
            'CSV' {
                $CSVSplat = @{
                    MailboxCSV = $MailboxCSV
                    NoBatch    = $true
                }
                $UserChoice = Import-MailboxCsvDecision @CSVSplat
            }
        }
        if ($UserChoice -ne 'Quit' ) {
            ($UserChoice).UserPrincipalName | Set-CloudLicense -ReportUserLicensesEnabled
        }
    }
}
