function Update-MailboxMovePermissionBatch {
    <#
    .SYNOPSIS
    Update BatchName from batches.xlsx found on SharePoint
    This will create a new file that you will need to copy to SharePoint
    It is a copy of the Batches.xlsx found on SharePoint, however it updates BatchName column based on your selection.

    .DESCRIPTION
    Update BatchName from batches.xlsx found on SharePoint
    This will create a new file that you will need to copy to SharePoint
    It is a copy of the Batches.xlsx found on SharePoint, however it updates BatchName column based on your selection.

    .PARAMETER SharePointURL
    Sharepoint url ex. https://fabrikam.sharepoint.com/sites/Contoso

    .PARAMETER ExcelFile
    Excel file found in "Shared Documents" of SharePoint site specified in SharePointURL
    ex. "Batches.xlsx"
    Minimum headers required are: BatchName, UserPrincipalName

    .EXAMPLE
    Update-MailboxMovePermissionBatch -SharePointURL 'https://fabrikam.sharepoint.com/sites/Contoso' -ExcelFile 'Batches.xlsx'

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $SharePointURL,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ExcelFile,

        [Parameter()]
        [switch]
        $IncludeMigrated
    )
    end {
        $UserInputBatch = Read-Host "Enter BatchName with which to update batches.xlsx"
        if ($UserInputBatch) {
            $LinkSplat = @{
                SharePointURL   = $SharePointURL
                ExcelFile       = $ExcelFile
                IncludeMigrated = $IncludeMigrated
                UserInputBatch  = $UserInputBatch
            }
            Invoke-UpdateMailboxMovePermissionBatch @LinkSplat
        }
    }
}
