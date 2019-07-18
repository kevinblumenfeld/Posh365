function Set-MailboxMovePermission {
    <#
    .SYNOPSIS
    Get permissions for on-premises mailboxes.
    The permissions that that mailbox has and those with permission to that mailbox

    .DESCRIPTION
    Get permissions for on-premises mailboxes.
    The permissions that that mailbox has and those with permission to that mailbox

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

    .EXAMPLE
    Set-MailboxMovePermission -RemoteHost mail.contoso.com -Tenant Contoso -MailboxCSV c:\scripts\batches.csv

    .EXAMPLE
    Set-MailboxMovePermission -SharePointURL 'https://fabrikam.sharepoint.com/sites/Contoso' -ExcelFile 'Batches.xlsx' -Tenant Contoso

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
        $Tenant
    )
    end {
        if ($Tenant -notmatch '.mail.onmicrosoft.com') {
            $Tenant = '{0}.mail.onmicrosoft.com' -f $Tenant
        }
        $SetPermSplat = @{ }
        switch ($PSBoundParameters.Keys) {
            'SharePointURL' { $SetPermSplat.Add('SharePointURL', $SharePointURL) }
            'ExcelFile' { $SetPermSplat.Add('ExcelFile', $ExcelFile) }
            'MailboxCSV' { $SetPermSplat.Add('MailboxCSV', $MailboxCSV) }
            'Tenant' { $SetPermSplat.Add('Tenant', $Tenant) }
            Default { }
        }
        $PermissionList = Set-MailboxMovePermissionResult @SetPermSplat
        $PermissionList
    }
}
