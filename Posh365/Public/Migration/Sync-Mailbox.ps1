function Sync-Mailbox {
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
    Path to csv of mailboxes.  Minimum headers required are: Batch, UserPrincipalName

    .PARAMETER RemoteHost
    This is the endpoint where the source mailboxes reside ex. cas2010.contoso.com

    .PARAMETER TargetDomain
    This is the tenant domain ex. if tenant is contoso.mail.onmicrosoft.com use contoso

    .PARAMETER GroupsToAddUserTo
    Provide one or more groups to add each user chosen to. -GroupsToAddUserTo "Human Resources", "Accounting"
    Requires AD Module

    .PARAMETER DeleteSavedCredential
    Erases credentials that are saved and encrypted on your computer

    .EXAMPLE
    Sync-Mailbox -RemoteHost cas2010.contoso.com -Tenant contoso -MailboxCSV c:\scripts\batches.csv -GroupsToAddUserTo "Office 365 E3"

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
                $UserChoice = Import-SharePointExcelDecision -SharePointURL $SharePointURL -ExcelFile $ExcelFile -Tenant $Tenant

            }
            'CSV' {
                $UserChoice = Import-MailboxCsvDecision -MailboxCSV $MailboxCSV
            }
        }

        if ($UserChoice -ne 'Quit' ) {
            Connect-Cloud -Tenant $Tenant -ExchangeOnline
            $Sync = @{
                RemoteHost   = $RemoteHost
                TargetDomain = $Tenant
            }
            $UserChoice | Start-MailboxSync @Sync
            foreach ($Group in $GroupsToAddUserTo) {
                $GuidList = $UserChoice | Get-ADUserGuid
                $GuidList | Add-UserToADGroup -Group $Group
            }
        }
    }
}

