function Get-MailboxMovePermissionLink {
    <#
    .SYNOPSIS
    Get permissions for on-premises mailboxes.
    The permissions that that mailbox has and those with permission to that mailbox
    This allows the user to reevaluate permission links - by reselecting users, permission types and permissions direction (if delegate and/or delegated)

    .DESCRIPTION
    Get permissions for on-premises mailboxes.
    The permissions that that mailbox has and those with permission to that mailbox
    This allows the user to reevaluate permission links - by reselecting users, permission types and permissions direction (if delegate and/or delegated)

    .PARAMETER SharePointURL
    Sharepoint url ex. https://fabrikam.sharepoint.com/sites/Contoso

    .PARAMETER ExcelFile
    Excel file found in "Shared Documents" of SharePoint site specified in SharePointURL
    ex. "Batches.xlsx"
    Minimum headers required are: BatchName, UserPrincipalName

    .EXAMPLE
    Get-MailboxMovePermissionLink -SharePointURL 'https://fabrikam.sharepoint.com/sites/Contoso' -ExcelFile 'Batches.xlsx'

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

        [Parameter()]
        [switch]
        $IncludeMigrated
    )
    end {
        $LinkSplat = @{
            SharePointURL   = $SharePointURL
            ExcelFile       = $ExcelFile
            IncludeMigrated = $IncludeMigrated
        }
        Invoke-GetMailboxMovePermissionLink @LinkSplat
    }
}
