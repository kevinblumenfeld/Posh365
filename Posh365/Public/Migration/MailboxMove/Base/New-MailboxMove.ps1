function New-MailboxMove {
    <#
    .SYNOPSIS
    Sync Mailboxes from On-Premises Exchange to Exchange Online
    Either CSV or Excel file from SharePoint can be used

    .DESCRIPTION
    Sync Mailboxes from On-Premises Exchange to Exchange Online
    Either CSV or Excel file from SharePoint can be used

    .PARAMETER SharePointURL
    Sharepoint url ex. https://fabrikam.sharepoint.com/sites/Contoso

    .PARAMETER ExcelFile
    Excel file found in "Shared Documents" of SharePoint site specified in SharePointURL
    ex. "Batches.xlsx"
    Minimum headers required are: BatchName, UserPrincipalName

    .PARAMETER MailboxCSV
    Path to csv of mailboxes. Minimum headers required are: BatchName, UserPrincipalName

    .PARAMETER RemoteHost
    This is the on-premises endpoint where the source mailboxes reside ex. mail.contoso.com

    .PARAMETER Tenant
    This is the tenant domain - where you are migrating to. Ex. if tenant is contoso.mail.onmicrosoft.com use contoso

    .PARAMETER GroupsToAddUserTo
    Provide one or more Active Directory Groups to add each user chosen to. -GroupsToAddUserTo "Human Resources", "Accounting"
    Requires AD Module. This is optional

    .EXAMPLE
    New-MailboxMove -RemoteHost mail.contoso.com -Tenant Contoso -MailboxCSV c:\scripts\batches.csv -GroupsToAddUserTo "Office 365 E3"

    .EXAMPLE
    New-MailboxMove -SharePointURL 'https://fabrikam.sharepoint.com/sites/Contoso' -ExcelFile 'Batches.xlsx' -RemoteHost mail.contoso.com -Tenant Contoso

    .NOTES
    General notes
    #>

    [CmdletBinding(DefaultParameterSetName = 'SharePoint')]
    [Alias('NMM')]
    param (
        [Parameter()]
        [switch]
        $TenantToTenant,

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
        [Alias('RemoteTenant')]
        [string]
        $RemoteHost,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('TargetDeliveryDomain')]
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
        $GroupsToAddUserTo
    )
    if ($TenantToTenant) {
        if ($Tenant -notmatch '\.onmicrosoft\.com') {
            $Tenant = '{0}.onmicrosoft.com' -f $Tenant
        }
        if ($RemoteHost -notmatch '\.onmicrosoft\.com') {
            $RemoteHost = '{0}.onmicrosoft.com' -f $RemoteHost
        }

    }
    else {
        if ($Tenant -notmatch '\.mail\.onmicrosoft\.com') {
            $Tenant = '{0}.mail.onmicrosoft.com' -f $Tenant
        }
    }
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
        if ($TenantToTenant) {
            $UserChoice | Invoke-T2TMailboxMove @Sync | Out-GridView -Title "Results of New Tenant to Tenant Mailbox Move"
        }
        else {
            $UserChoice | Invoke-NewMailboxMove @Sync | Out-GridView -Title "Results of New Mailbox Move"
        }
        foreach ($Group in $GroupsToAddUserTo) {
            $GuidList = $UserChoice | Get-ADUserGuid
            $GuidList | Add-UserToADGroup -Group $Group
        }
    }
}
