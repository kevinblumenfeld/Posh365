function Set-BTUser {
    <#
    .SYNOPSIS
    Create New MSPC customer end user

    .DESCRIPTION
    Create New MSPC customer end user

    .PARAMETER SharePointURL
    Sharepoint url ex. https://fabrikam.sharepoint.com/sites/Contoso

    .PARAMETER ExcelFile
    Excel file found in "Shared Documents" of SharePoint site specified in SharePointURL
    ex. "Batchex.xlsx"

    .PARAMETER MailboxCSV
    Path to csv of mailboxes. Minimum headers required are: BatchName, UserPrincipalName

    .EXAMPLE
    Set-BTUser -MailboxCSV C:\Scripts\testbatches.csv -TargetEmailSuffix fabrikam.com

    .EXAMPLE
    Set-BTUser -SharePointURL 'https://contoso.sharepoint.com/sites/o365-fabrikam/' -ExcelFile 'Batches.xlsx'

    .EXAMPLE
    This example finds the batches file in the root of the Teams "General" folder on the SharePoint site
    Set-BTUser -SharePointURL 'https://contoso.sharepoint.com/sites/o365-fabrikam/' -ExcelFile '/General/batches.xlsx'

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
        $TargetEmailSuffix,

        [Parameter(ParameterSetName = 'SharePoint')]
        [ValidateNotNullOrEmpty()]
        [switch]
        $PassThruResultsToCreateNewUsers
    )
    end {
        switch ($PSCmdlet.ParameterSetName) {
            'SharePoint' {
                $SharePointSplat = @{
                    SharePointURL = $SharePointURL
                    ExcelFile     = $ExcelFile
                }
                $UserChoice = Import-BTSharePointExcelDecision @SharePointSplat
            }
            'CSV' {
                $UserChoice = Import-MailboxCsvDecisionDomainChoice -MailboxCSV $MailboxCSV -ChooseDomain
            }
        }
        if ($UserChoice -ne 'Quit' ) {
            if (-not $PassThruResultsToCreateNewUsers) {
                $UserChoice | Invoke-SetBTUser | Out-GridView -Title "Results of Set BitTitan End Users"
            }
            else {
                $CreateNewFilter = $UserChoice | Invoke-SetBTUser | Out-GridView -Title "Results of Set BitTitan End Users" -OutputMode Multiple
                $NewUsers = $UserChoice | Where-Object { $_.PrimarySmtpAddress -in $CreateNewFilter.PrimarySmtpAddress } | Out-GridView -OutputMode Multiple -Title "Choose which users to newly create"
                $NewUsers | Invoke-NewBTUser | Out-GridView -Title "Results of New BitTitan End Users"
            }
        }
    }
}

