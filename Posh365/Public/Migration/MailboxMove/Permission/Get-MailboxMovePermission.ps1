function Get-MailboxMovePermission {
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

    .EXAMPLE
    Get-MailboxMovePermission -MailboxCSV c:\scripts\batches.csv

    .EXAMPLE
    Get-MailboxMovePermission -SharePointURL 'https://fabrikam.sharepoint.com/sites/Contoso' -ExcelFile 'Batches.xlsx'

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
        $Remove,

        [Parameter()]
        [switch]
        $PassThru
    )
    end {
        switch ($PSCmdlet.ParameterSetName) {
            'SharePoint' {
                $SharePointSplat = @{
                    SharePointURL  = $SharePointURL
                    ExcelFile      = $ExcelFile
                    NoBatch        = $true
                    NoConfirmation = $true
                }
                $UserChoice = Import-SharePointExcelDecision @SharePointSplat
            }
            'CSV' {
                $UserChoice = Import-MailboxCsvDecision -MailboxCSV $MailboxCSV
            }
        }
        $UserChoiceRegex = ($UserChoice.UserPrincipalName | ForEach-Object { [Regex]::Escape($_) }) -join '|'
        $PermissionChoice = Get-PermissionDecision
        $DirectionChoice = Get-PermissionDirectionDecision

        $PermissionResult = @{
            SharePointURL    = $SharePointURL
            ExcelFile        = $ExcelFile
            UserChoiceRegex  = $UserChoiceRegex
            PermissionChoice = $PermissionChoice
            DirectionChoice  = $DirectionChoice
        }
        if ($Remove) {
            $PermissionResult.Add('Remove', $true)
        }
        if ($PassThru) {
            Get-MailboxMovePermissionResult @PermissionResult | Out-GridView -Title "Permission Results" -OutputMode Multiple
        }
        else {
            Get-MailboxMovePermissionResult @PermissionResult | Out-GridView -Title "Permission Results"
        }
    }
}
