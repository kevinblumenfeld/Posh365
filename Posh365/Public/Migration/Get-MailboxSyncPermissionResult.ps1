
function Get-MailboxSyncPermissionResult {
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

        if ($PermissionChoice -match "FullAccess|SendAs|SendOnBehalf") {
            $SPPermMailbox = @{
                SharePointURL  = $SharePointURL
                ExcelFile      = 'Permissions.xlsx'
                WorksheetName  = 'Mailbox'
                Tenant         = $Tenant
                NoBatch        = $true
                NoConfirmation = $true
            }
            $MailboxPermission = Import-SharePointExcel @SPPermMailbox
            $DelegateResult = @{
                PermissionChoice  = $PermissionChoice
                DirectionChoice   = $DirectionChoice
                MailboxPermission = $MailboxPermission
            }
            Get-MailboxSyncDelegateResult @DelegateResult | Select-Object @(
                @{
                    Name       = 'Location'
                    Expression = { 'Mailbox' }
                }
                'Object'
                'UserPrincipalName'
                'Granted'
                'GrantedUPN'
                @{
                    Name       = 'Permission'
                    Expression = { $_.Permission }
                }
            )
        }
        ####
        if ($PermissionChoice -match "Folder") {
            $SPPermMailbox = @{
                SharePointURL  = $SharePointURL
                ExcelFile      = 'Permissions.xlsx'
                WorksheetName  = 'Folder'
                Tenant         = $Tenant
                NoBatch        = $true
                NoConfirmation = $true
            }
            $FolderPermission = Import-SharePointExcel @SPPermMailbox
            $FolderResult = @{
                DirectionChoice  = $DirectionChoice
                FolderPermission = $FolderPermission
            }
            Get-MailboxSyncFolderResult @FolderResult | Select-Object @(
                @{
                    Name       = 'Location'
                    Expression = { $_.Folder }
                }
                'Object'
                'UserPrincipalName'
                'Granted'
                'GrantedUPN'
                @{
                    Name       = 'Permission'
                    Expression = { $_.AccessRights }
                }
            )
        }
    }
}
