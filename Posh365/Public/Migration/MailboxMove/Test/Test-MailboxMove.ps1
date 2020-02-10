Function Test-MailboxMove {
    <#
    .SYNOPSIS
    Test Mailbox Moves

    .DESCRIPTION
    Test Mailbox Moves prior to migrating.. RESULT column says if pass or fails
    be aware this will fail if primarysmtpaddress does not match UPN.  However, you can still see individual test results.

    .PARAMETER SharePointURL
    Sharepoint url ex. https://fabrikam.sharepoint.com/sites/Contoso

    .PARAMETER ExcelFile
    Excel file found in "Shared Documents" of SharePoint site specified in SharePointURL
    ex. "Batches.xlsx"

    .PARAMETER MailboxCSV
    If using a csv instead of sharepoint url excel file

    .PARAMETER ExportToExcel
    Exports in Excel format to Posh365 folder on Desktop. Also outputs to OutGrid-View

    .PARAMETER SkipUpnMatchSmtpTest
    Skips the UPN must match PrimarySmtpAddress test

    .EXAMPLE
    Test-MailboxMove -SharePointURL 'https://contoso.sharepoint.com/sites/fabrikam' -ExcelFile 'Batches.xlsx'

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
        [ValidateNotNullOrEmpty()]
        [switch]
        $ExportToExcel,

        [Parameter()]
        [switch]
        $SkipUpnMatchSmtpTest
    )
    end {
        $PoshPath = Join-Path ([Environment]::GetFolderPath("Desktop")) -ChildPath 'Posh365'
        $null = New-Item -ItemType Directory -Path $PoshPath  -ErrorAction SilentlyContinue
        switch ($PSCmdlet.ParameterSetName) {
            'SharePoint' {
                $SharePointSplat = @{
                    SharePointURL = $SharePointURL
                    ExcelFile     = $ExcelFile
                }
                $UserChoice = Import-SharePointExcelDecision @SharePointSplat
            }
            'CSV' {
                $UserChoice = Import-MailboxCsvDecision -MailboxCSV $MailboxCSV
            }
        }
        if ($UserChoice -ne 'Quit' ) {
            $TestSelect = @(
                'BatchName', 'OrganizationalUnit', 'MailboxType', 'DisplayName', 'Result', 'AccountDisabled'
                'UpnMatchesPrimarySmtp', 'RoutingAddressValid', 'IsDirSynced', 'EmailAddressesValid'
                'MailboxExists', 'ErrorType', 'ErrorValue', 'UserPrincipalName'
            )
            if ($ExportToExcel) {
                Write-Host 'Testing & Exporting... Please standby' -ForegroundColor Green
                $TestResult = Invoke-TestMailboxMove -UserList $UserChoice -SkipUpnMatchSmtpTest:$SkipUpnMatchSmtpTest | Select-Object $TestSelect
                $TestResult | Out-GridView -Title 'Results of Test Mailbox Move'
                $TestResult | Export-PoshExcel (Join-Path $PoshPath ('PreFlight_{0}.xlsx' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm')))
                Write-Host 'Excel file saved in the folder Posh365 on the Desktop' -ForegroundColor Green
            }
            else {
                Invoke-TestMailboxMove -UserList $UserChoice -SkipUpnMatchSmtpTest:$SkipUpnMatchSmtpTest | Select-Object $TestSelect | Out-GridView -Title 'Results of Test Mailbox Move'
            }
        }
    }
}
