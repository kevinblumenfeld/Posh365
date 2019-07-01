function New-MailboxSync {
    <#
    .SYNOPSIS
    Sync Mailboxes from On-Premises Exchange to Exchange Online
    Either CSV or Excel file from SharePoint can be used

    .DESCRIPTION
    Sync Mailboxes from On-Premises Exchange to Exchange Online
    Either CSV or Excel file from SharePoint can be used

    .PARAMETER SharePointURL
    Sharepoint url ex. https://contoso.sharepoint.com/sites/fabrikam/

    .PARAMETER ExcelFile
    Excel file found in "Shared Documents" of SharePoint site specified in SharePointURL
    ex. "Batchex.xlsx"

    .PARAMETER MailboxCSV
    Path to csv of mailboxes.  Minimum headers required are: BatchName, UserPrincipalName

    .PARAMETER RemoteHost
    This is the on-premises endpoint where the source mailboxes reside ex. cas2010.contoso.com

    .PARAMETER Tenant
    This is the tenant domain ex. if tenant is contoso.mail.onmicrosoft.com use contoso

    .PARAMETER GroupsToAddUserTo
    Provide one or more Active Directory Groups to add each user chosen to. -GroupsToAddUserTo "Human Resources", "Accounting"
    Requires AD Module

    .PARAMETER DeleteSavedCredential
    Erases credentials that are saved and encrypted on your computer

    .EXAMPLE
    New-MailboxSync -RemoteHost cas2010.contoso.com -Tenant contoso -MailboxCSV c:\scripts\batches.csv -GroupsToAddUserTo "Office 365 E3"

    .NOTES
    General notes
    #>

    [CmdletBinding(DefaultParameterSetName = 'SharePoint')]
    [Alias('New-MailboxSync')]
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
        $RemoteHost,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Tenant,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]
        $BadItemLimit = 20,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]
        $LargeItemLimit = 20,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $GroupsToAddUserTo,

        [Parameter()]
        [switch]
        $DeleteSavedCredential
    )
    end {
        if ($Tenant -notmatch '.mail.onmicrosoft.com') {
            $Tenant = '{0}.mail.onmicrosoft.com' -f $Tenant
        }
        if ($DeleteSavedCredential) {
            $DelSaved = @{
                RemoteHost            = $RemoteHost
                TargetDomain          = $Tenant
                DeleteSavedCredential = $true
            }
            Start-MailboxSync @DelSaved
            break
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
            $Sync = @{
                RemoteHost = $RemoteHost
                Tenant     = $Tenant
            }
            if ($BadItemLimit) {
                $Sync.Add('BadItemLimit', $BadItemLimit)
            }
            if ($LargeItemLimit) {
                $Sync.Add('LargeItemLimit', $LargeItemLimit)
            }
            $UserChoice | Start-MailboxSync @Sync
            foreach ($Group in $GroupsToAddUserTo) {
                $GuidList = $UserChoice | Get-ADUserGuid
                $GuidList | Add-UserToADGroup -Group $Group
            }
        }
    }
}
