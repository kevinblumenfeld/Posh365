function Add-MailboxMovePermission {
    <#
    .SYNOPSIS
    Adds Mailbox and Folder Permissions to 365 Mailboxes

    .DESCRIPTION
    Adds Mailbox and Folder Permissions to 365 Mailboxes

    .PARAMETER SharePointURL
    Sharepoint url ex. https://fabrikam.sharepoint.com/sites/Contoso

    .PARAMETER ExcelFile
    Excel file found in "Shared Documents" of SharePoint site specified in SharePointURL
    ex. "Batchex.xlsx"

    .PARAMETER AutoMap
    Use to set AutoMapping to $true.  Will only have an effect on Full Access permissions.

    .EXAMPLE
    Add-MailboxMovePermission -SharePointURL 'https://contoso.sharepoint.com/sites/fabrikam/' -ExcelFile 'batches.xlsx'

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
        [ValidateNotNullOrEmpty()]
        [switch]
        $AutoMap
    )
    end {

        $GetPermSplat = @{
            'PassThru'         = $true
            'IncludeMigrated'  = $true
            'UseApplyFunction' = $true
        }
        $AddPermSplat = @{'AutoMap' = $AutoMap }
        switch ($PSBoundParameters.Keys) {
            'SharePointURL' { $GetPermSplat.Add('SharePointURL', $SharePointURL) }
            'ExcelFile' { $GetPermSplat.Add('ExcelFile', $ExcelFile) }
            Default { }
        }
        $PermissionList = Get-MailboxMovePermission @GetPermSplat
        $PermissionList | Invoke-AddMailboxMovePermission @AddPermSplat | Out-GridView -Title 'Mailbox move permission add results'
    }
}

