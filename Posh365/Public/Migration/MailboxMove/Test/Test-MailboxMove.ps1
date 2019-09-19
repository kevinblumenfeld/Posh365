Function Test-MailboxMove {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER SharePointURL
    Parameter description

    .PARAMETER ExcelFile
    Parameter description

    .PARAMETER MailboxCSV
    Parameter description

    .EXAMPLE
    An example

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
