function Invoke-SetMailboxMoveLicense {
    <#
    .SYNOPSIS
    Sets Office 365 licenses during a migration project
    Either CSV or Excel file from SharePoint can be used

    .DESCRIPTION
    Sets Office 365 licenses during a migration project
    Either CSV or Excel file from SharePoint can be used

    .PARAMETER SharePointURL
    Sharepoint url ex. https://fabrikam.sharepoint.com/sites/Contoso

    .PARAMETER ExcelFile
    Excel file found in "Shared Documents" of SharePoint site specified in SharePointURL
    ex. "Batches.xlsx"
    Minimum headers required are: BatchName, UserPrincipalName

    .PARAMETER MailboxCSV
    Path to csv of mailboxes. Minimum headers required are: BatchName, UserPrincipalName

    .EXAMPLE
    Set-MailboxMoveLicense -MailboxCSV c:\scripts\batches.csv

    .EXAMPLE
    Set-MailboxMoveLicense -SharePointURL 'https://fabrikam.sharepoint.com/sites/Contoso' -ExcelFile 'Batches.xlsx'

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
        $MailboxCSV,

        [Parameter()]
        [switch]
        $NoBatch,

        [Parameter()]
        [switch]
        $UseTargetUserPrincipalNameColumn


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
            $LicenseDecision = Get-LicenseDecision
            $LicenseOptions = @{ }
            foreach ($License in $LicenseDecision.Options) {
                $LicenseOptions.Add($License, $true)
            }
            if ($UseTargetUserPrincipalNameColumn) {
                ($UserChoice).TargetUserPrincipalName | Set-CloudLicense @LicenseOptions | Out-GridView -Title "Results of Set Mailbox Move License (using TargetUserPrincipalName column)"
            }
            else {
                ($UserChoice).UserPrincipalName | Set-CloudLicense @LicenseOptions | Out-GridView -Title "Results of Set Mailbox Move License"
            }

        }
    }
}
