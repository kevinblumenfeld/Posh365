function New-MWMailboxMove {
    <#
    .SYNOPSIS
    Create New "Mailbox Moves" with Migration Wiz from Source Tenant to Target Tenant

    .DESCRIPTION
    Create New "Mailbox Moves" with Migration Wiz from Source Tenant to Target Tenant

    .PARAMETER SharePointURL
    Sharepoint url ex. https://fabrikam.sharepoint.com/sites/Contoso

    .PARAMETER ExcelFile
    Excel file found in "Shared Documents" of SharePoint site specified in SharePointURL
    ex. "Batches.xlsx"
    Minimum headers required are: BatchName, UserPrincipalName

    .PARAMETER MailboxCSV
    Path to csv of mailboxes. Minimum headers required are: BatchName, UserPrincipalName

    .PARAMETER UseTenantAddressAsSource
    Use the user@domain.onmicrosoft.com (tenant address) as the source email address

    .PARAMETER UseTargetPrimaryAsTarget
    Use the primarysmtpaddress in the target tenant.  Primarily used for 365 to 365 where the domain name changes

    .EXAMPLE
    New-MWMailboxMove -MailboxCSV C:\Scripts\testbatches.csv -TargetEmailSuffix fabrikam.com

    .EXAMPLE
    New-MWMailboxMove -SharePointURL 'https://contoso.sharepoint.com/sites/o365-fabrikam/' -ExcelFile 'Batches.xlsx'

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
        [switch]
        $UseTenantAddressAsSource,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [switch]
        $UseTargetPrimaryAsTarget
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
            $Sync = @{
                UseTenantAddressAsSource = $UseTenantAddressAsSource
                UseTargetPrimaryAsTarget = $UseTargetPrimaryAsTarget
            }
            $UserChoice | Invoke-NewMWMailboxMove @Sync | Out-GridView -Title "Results of MigrationWiz New Mailbox Move"
        }
    }
}
