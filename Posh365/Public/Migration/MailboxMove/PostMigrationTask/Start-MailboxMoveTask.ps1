function Start-MailboxMoveTask {
    <#
    .SYNOPSIS
    Once a mailbox has been migrated to Office 365, often there are post-migration tasks.
    For example a user's address book policy (ABP), if not the default will need to be applied.

    .DESCRIPTION
    Once a mailbox has been migrated to Office 365, often there are post-migration tasks.
    For example a user's address book policy (ABP), if not the default will need to be applied.

    .PARAMETER SharePointURL
    Sharepoint url ex. https://fabrikam.sharepoint.com/sites/Contoso

    .PARAMETER ExcelFile
    Excel file found in "Shared Documents" of SharePoint site specified in SharePointURL
    ex. "Batchex.xlsx"
    Minimum headers required are: BatchName, UserPrincipalName

    .PARAMETER MailboxCSV
    Path to csv of mailboxes. Minimum headers required are: BatchName, UserPrincipalName

    .PARAMETER Tenant
    This is the tenant domain - where you are migrating to. Ex. if tenant is contoso.mail.onmicrosoft.com use contoso

    .PARAMETER AddressBookPolicy
    For each UserPrincipalName selected, the Address Book Policy (ABP) will be updated to the value in AddressBookPolicy column

    .EXAMPLE
    Start-MailboxMoveTask -AddressBookPolicy -SharePointURL 'https://fabrikam.sharepoint.com/sites/Contoso' -ExcelFile 'Batches.xlsx' -Tenant mkevin

    .NOTES
    Connect to Exchange Online
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

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Tenant,

        [Parameter()]
        [switch]
        $AddressBookPolicy
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
            if ($UserChoice) {
                if ($AddressBookPolicy) {
                    $UserChoice | Sync-AddressBookPolicy
                }
            }
        }
    }
}
