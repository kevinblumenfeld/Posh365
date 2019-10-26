function Get-MailboxMovePermissionLinkResult {
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
        $IncludeMigrated,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $UserChoiceRegex,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $PermissionChoice,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $DirectionChoice,

        [Parameter()]
        $BatchHash,

        [Parameter()]
        $BatchLink,

        [Parameter()]
        $MailboxPermission,

        [Parameter()]
        $FolderPermission
    )
    end {
        if ($PermissionChoice -match "FullAccess|SendAs|SendOnBehalf") {
            $DelegateResult = @{
                PermissionChoice  = $PermissionChoice
                DirectionChoice   = $DirectionChoice
                MailboxPermission = $MailboxPermission
            }
            Get-MailboxMoveDelegateResult @DelegateResult | Where-Object { $_.PrimarySmtpAddress -and $_.GrantedSMTP -and
                $BatchHash[$_.PrimarySmtpAddress].isMigrated -ne (-not $IncludeMigrated) -and $BatchHash[$_.GrantedSMTP].isMigrated -ne (-not $IncludeMigrated)
            } | Select-Object @(
                @{
                    Name       = 'BatchName'
                    Expression = { $BatchHash[$_.PrimarySmtpAddress].BatchName }
                }
                @{
                    Name       = 'Location'
                    Expression = { 'Mailbox' }
                }
                'Object'
                'PrimarySmtpAddress'
                'Granted'
                'GrantedSMTP'
                'Permission'
                @{
                    Name       = 'Type'
                    Expression = 'DisplayType'
                }
                @{
                    Name       = 'GrantedBatch'
                    Expression = { $BatchHash[$_.GrantedSMTP].BatchName }
                }
            )
        }
        if ($PermissionChoice -match "Folder") {
            $FolderResult = @{
                DirectionChoice  = $DirectionChoice
                FolderPermission = $FolderPermission
            }
            Get-MailboxMoveFolderResult @FolderResult | Where-Object { $_.PrimarySmtpAddress -and $_.GrantedSMTP -and
                $BatchHash[$_.PrimarySmtpAddress].isMigrated -ne (-not $IncludeMigrated) -and $BatchHash[$_.GrantedSMTP].isMigrated -ne (-not $IncludeMigrated)
            } | Select-Object @(
                @{
                    Name       = 'BatchName'
                    Expression = { $BatchHash[$_.PrimarySmtpAddress].BatchName }
                }
                @{
                    Name       = 'Location'
                    Expression = 'Folder'
                }
                'Object'
                'PrimarySmtpAddress'
                'Granted'
                'GrantedSMTP'
                @{
                    Name       = 'Permission'
                    Expression = 'AccessRights'
                }
                @{
                    Name       = 'Type'
                    Expression = 'DisplayType'
                }
                @{
                    Name       = 'GrantedBatch'
                    Expression = { $BatchHash[$_.GrantedSMTP].BatchName }
                }
            )
        }
    }
}
