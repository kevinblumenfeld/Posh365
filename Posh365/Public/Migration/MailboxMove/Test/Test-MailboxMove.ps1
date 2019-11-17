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
        $MailboxCSV
    )
    end {
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
                'OrganizationalUnit', 'MailboxType', 'DisplayName', 'Result', 'AccountDisabled'
                'UpnMatchesPrimarySmtp', 'RoutingAddressValid', 'IsDirSynced', 'EmailAddressesValid'
                'MailboxExists', 'ErrorType', 'ErrorValue', 'UserPrincipalName'
            )
            Invoke-TestMailboxMove -UserList $UserChoice | Select-Object $TestSelect | Out-GridView -Title "Results of Test Mailbox Move"
        }
    }
}
