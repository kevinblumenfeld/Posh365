
function Get-MailboxMovePermissionResult {
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

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $UserChoiceRegex,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $PermissionChoice,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $DirectionChoice
    )
    end {
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
            Get-MailboxMoveDelegateResult @DelegateResult | Select-Object @(
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
                @{
                    Name       = 'Type'
                    Expression = { $_.DisplayType }
                }
            )
        }
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
            Get-MailboxMoveFolderResult @FolderResult | Select-Object @(
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
                @{
                    Name       = 'Type'
                    Expression = { $_.DisplayType }
                }
            )
        }
    }
}
