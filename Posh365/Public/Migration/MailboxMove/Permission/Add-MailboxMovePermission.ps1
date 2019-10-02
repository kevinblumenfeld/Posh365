function Add-MailboxMovePermission {
    [CmdletBinding(DefaultParameterSetName = 'SharePoint')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'SharePoint')]
        [ValidateNotNullOrEmpty()]
        [string]
        $SharePointURL,

        [Parameter(Mandatory, ParameterSetName = 'SharePoint')]
        [ValidateNotNullOrEmpty()]
        [string]
        $ExcelFile
    )
    end {

        $SetPermSplat = @{'PassThru' = $true }
        switch ($PSBoundParameters.Keys) {
            'SharePointURL' { $SetPermSplat.Add('SharePointURL', $SharePointURL) }
            'ExcelFile' { $SetPermSplat.Add('ExcelFile', $ExcelFile) }
            'MailboxCSV' { $SetPermSplat.Add('MailboxCSV', $MailboxCSV) }
            Default { }
        }
        $PermissionList = Get-MailboxMovePermission @SetPermSplat
        $PermissionList | Invoke-AddMailboxMovePermission | Out-GridView -Title 'Mailbox move permission add results'
    }
}

