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

        $SetPermSplat = @{'PassThru' = $true }
        $AddPerm = @{'AutoMap' = $AutoMap }
        switch ($PSBoundParameters.Keys) {
            'SharePointURL' { $SetPermSplat.Add('SharePointURL', $SharePointURL) }
            'ExcelFile' { $SetPermSplat.Add('ExcelFile', $ExcelFile) }
            Default { }
        }
        $PermissionList = Get-MailboxMovePermission @SetPermSplat
        $PermissionList | Invoke-AddMailboxMovePermission @AddPerm | Out-GridView -Title 'Mailbox move permission add results'
    }
}

