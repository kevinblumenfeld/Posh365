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
        $SetPermSplat = @{'PassThru' = $true }
        switch ($PSBoundParameters.Keys) {
            'SharePointURL' { $SetPermSplat.Add('SharePointURL', $SharePointURL) }
            'ExcelFile' { $SetPermSplat.Add('ExcelFile', $ExcelFile) }
            'MailboxCSV' { $SetPermSplat.Add('MailboxCSV', $MailboxCSV) }
            'Tenant' { $SetPermSplat.Add('Tenant', $Tenant) }
            Default { }
        }
        $PermissionList = Get-MailboxMovePermission @SetPermSplat
        $PermissionList | Invoke-AddMailboxMovePermission | Out-GridView -Title 'Mailbox move permission add results'
    }
}
