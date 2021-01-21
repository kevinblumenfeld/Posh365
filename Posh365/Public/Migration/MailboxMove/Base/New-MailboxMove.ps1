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
    $params = @{
    SharePointURL = 'https://contoso.sharepoint.com/sites/migrate'
    ExcelFile     = 'Batches.xlsx'
    RemoteHost    = 'hybrid.contoso.com'
    Tenant        = 'contoso'
    }
    New-MailboxMove @params

    .EXAMPLE
    # For GCC use the full tenant adderess like in the example:

    $params = @{
    SharePointURL = 'https://contoso.sharepoint.com/sites/migrate'
    ExcelFile     = 'Batches.xlsx'
    RemoteHost    = 'hybrid.contoso.com'
    Tenant        = 'contoso.mail.onmicrosoft.us'
    }
    New-MailboxMove @params

    .EXAMPLE
    New-MailboxMove -SharePointURL 'https://fabrikam.sharepoint.com/sites/Contoso' -ExcelFile 'Batches.xlsx' -RemoteHost mail.contoso.com -Tenant Contoso

    .NOTES
    General notes
    #>

    [CmdletBinding(DefaultParameterSetName = 'PlaceHolder')]
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

        [Parameter(Mandatory, ParameterSetName = 'Object')]
        [ValidateNotNullOrEmpty()]
        $Object,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('RemoteTenant')]
        [string]
        $RemoteHost,

        [Parameter()]
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
        [int]
        $IncrementalSyncIntervalHours,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $GroupsToAddUserTo
    )
    if ($TenantToTenant) {
        if ($Tenant -notmatch '\.onmicrosoft\.com|\.onmicrosoft\.us') {
            $Tenant = '{0}.onmicrosoft.com' -f $Tenant
        }
        if ($RemoteHost -notmatch '\.onmicrosoft\.com|\.onmicrosoft\.us') {
            $RemoteHost = '{0}.onmicrosoft.com' -f $RemoteHost
        }
    }
    else {
        if ($Tenant -notmatch '\.mail\.onmicrosoft\.com|\.onmicrosoft\.us') {
            $Tenant = Get-AcceptedDomain | Where-Object { $_.DomainName -like '*.mail.onmicrosoft.*' } | Select-Object -ExpandProperty DomainName
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
        'Object' {
            $UserChoice = Import-MailboxCsvDecision -Object $Object
        }
    }
    if ($UserChoice -ne 'Quit' ) {
        $Sync = @{
            RemoteHost = $RemoteHost
            Tenant     = $Tenant
        }
        if ($BadItemLimit) {
            $Sync['BadItemLimit'] = $BadItemLimit
        }
        if ($LargeItemLimit) {
            $Sync['LargeItemLimit'] = $LargeItemLimit
        }
        if ($TenantToTenant) {
            $Sync['IncrementalSyncInterval'] = $IncrementalSyncIntervalHours
            $UserChoice | Invoke-T2TNewMailboxMove @Sync | Out-GridView -Title "Results of New Tenant to Tenant Mailbox Move"
        }
        else {
            if ($IncrementalSyncIntervalHours) {
                $Sync['IncrementalSyncInterval'] = $IncrementalSyncIntervalHours
            }
            $UserChoice | Invoke-NewMailboxMove @Sync | Out-GridView -Title "Results of New Mailbox Move"
        }
        foreach ($Group in $GroupsToAddUserTo) {
            $GuidList = $UserChoice | Get-ADUserGuid
            $GuidList | Add-UserToADGroup -Group $Group
        }
    }
}
