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

    .PARAMETER Tenant
    This is the tenant domain - where you are migrating to. Ex. if tenant is contoso.mail.onmicrosoft.com use contoso

    .EXAMPLE
    Get-MailboxMovePermission -RemoteHost mail.contoso.com -Tenant Contoso -MailboxCSV c:\scripts\batches.csv

    .EXAMPLE
    Get-MailboxMovePermission -SharePointURL 'https://fabrikam.sharepoint.com/sites/Contoso' -ExcelFile 'Batches.xlsx' -Tenant Contoso

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
        $Tenant,

        [Parameter()]
        [switch]
        $Remove,

        [Parameter()]
        [switch]
        $PassThru
    )
    end {
        if ($Tenant -notmatch '.mail.onmicrosoft.com') {
            $Tenant = '{0}.mail.onmicrosoft.com' -f $Tenant
        }
        switch ($PSCmdlet.ParameterSetName) {
            'SharePoint' {
                $SharePointSplat = @{
                    SharePointURL  = $SharePointURL
                    ExcelFile      = $ExcelFile
                    Tenant         = $Tenant
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
            Tenant           = $Tenant
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
