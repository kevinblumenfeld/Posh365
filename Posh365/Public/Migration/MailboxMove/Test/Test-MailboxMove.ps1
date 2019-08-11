Function Test-MailboxMove {
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

        [Parameter(Mandatory, ParameterSetName = 'SharePoint')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Tenant,

        [Parameter(Mandatory, ParameterSetName = 'CSV')]
        [ValidateNotNullOrEmpty()]
        [string]
        $MailboxCSV
    )
    end {
        if ($Tenant -notmatch '.mail.onmicrosoft.com') {
            $Tenant = '{0}.mail.onmicrosoft.com' -f $Tenant
        }
        switch ($PSCmdlet.ParameterSetName) {
            'SharePoint' {
                $SharePointSplat = @{
                    SharePointURL = $SharePointURL
                    ExcelFile     = $ExcelFile
                    Tenant        = $Tenant
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
