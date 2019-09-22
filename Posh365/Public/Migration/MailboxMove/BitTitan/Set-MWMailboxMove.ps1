function Set-MWMailboxMove {
    <#
    .SYNOPSIS
    Sets "Mailbox Moves" for Migration Wiz

    .DESCRIPTION
    Sets "Mailbox Moves" for Migration Wiz

    .PARAMETER SharePointURL
    Sharepoint url ex. https://fabrikam.sharepoint.com/sites/Contoso

    .PARAMETER ExcelFile
    Excel file found in "Shared Documents" of SharePoint site specified in SharePointURL

    .PARAMETER MailboxCSV
    Path to csv of mailboxes. Minimum headers required are: BatchName, UserPrincipalName

    .EXAMPLE
    Set-MWMailboxMove -SharePointURL 'https://contoso.sharepoint.com/sites/o365-fabrikam/' -ExcelFile 'Batches.xlsx'

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
        [switch]
        $SwapSourcePrimaryWithSourceTenant,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [switch]
        $SwapSourceTenantWithSourcePrimary
    )
    end {
        if ($SwapSourcePrimaryWithSourceTenant -and $SwapSourceTenantWithSourcePrimary) {
            Write-Host "Please choose either SwapSourceTenantWithSourcePrimary or SwapSourcePrimaryWithSourceTenant, not both." -ForegroundColor Red
            return
        }
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
            $Sync = @{ }
            switch ($true) {
                $SwapSourcePrimaryWithSourceTenant { $Sync.Add('SwapSourcePrimaryWithSourceTenant', $true) }
                $SwapSourceTenantWithSourcePrimary { $Sync.Add('SwapSourceTenantWithSourcePrimary', $true) }
                Default { }
            }
            if ($Sync.Keys) {
                $UserChoice | Invoke-SetMWMailboxMove @Sync | Out-GridView -Title "Results of MigrationWiz Set Mailbox Move"
            }
            else {
                Write-Host "Run the command again and choose something to set with one of the parameters" -ForegroundColor White
            }
        }
    }
}
