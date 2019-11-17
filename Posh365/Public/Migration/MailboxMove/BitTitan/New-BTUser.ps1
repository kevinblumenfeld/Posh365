function New-BTUser {
    <#
    .SYNOPSIS
    Create New MSPC customer end user

    .DESCRIPTION
    Create New MSPC customer end user

    .PARAMETER SharePointURL
    Sharepoint url ex. https://fabrikam.sharepoint.com/sites/Contoso

    .PARAMETER ExcelFile
    Excel file found in "Shared Documents" of SharePoint site specified in SharePointURL
    ex. "Batches.xlsx"

    .PARAMETER MailboxCSV
    Path to csv of mailboxes. Minimum headers required are: BatchName, UserPrincipalName

    .EXAMPLE
    New-BTUser -MailboxCSV C:\Scripts\testbatches.csv -TargetEmailSuffix fabrikam.com

    .EXAMPLE
    New-BTUser -SharePointURL 'https://contoso.sharepoint.com/sites/o365-fabrikam/' -ExcelFile 'Batches.xlsx'

    .EXAMPLE
    This example finds the batches file in the root of the Teams "General" folder on the SharePoint site
    New-BTUser -SharePointURL 'https://contoso.sharepoint.com/sites/o365-fabrikam/' -ExcelFile '/General/batches.xlsx'

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
        $TargetEmailSuffix
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
            $UserChoice | Invoke-NewBTUser | Out-GridView -Title "Results of New BitTitan End Users"
        }
    }
}
