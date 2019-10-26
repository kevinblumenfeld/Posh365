function Invoke-GetMailboxMovePermissionLink {
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
        $IncludeMigrated
    )
    end {
        switch ($PSCmdlet.ParameterSetName) {
            'SharePoint' {
                $SharePointSplat = @{
                    SharePointURL = $SharePointURL
                    ExcelFile     = $ExcelFile
                }
                $BatchLink = Import-SharePointExcel @SharePointSplat
                $UserDecisionSplat = @{
                    DecisionObject = $BatchLink
                    NoBatch        = $true
                    NoConfirmation = $true
                }
                $UserChoice = Get-UserDecision @UserDecisionSplat
                $BatchHash = @{ }
                $BatchLink | ForEach-Object {
                    if (-not $BatchHash.ContainsKey($_.PrimarySMTPAddress)) {
                        $BatchHash.Add($_.PrimarySMTPAddress, @{
                                BatchName  = $_.BatchName
                                IsMigrated = $_.IsMigrated
                            })
                    }
                }
                $SPPermMailbox = @{
                    SharePointURL  = $SharePointURL
                    ExcelFile      = 'Permissions.xlsx'
                    WorksheetName  = 'Mailbox'
                    NoBatch        = $true
                    NoConfirmation = $true
                }
                $MailboxPermission = Import-SharePointExcel @SPPermMailbox
                $SPPermMailbox = @{
                    SharePointURL  = $SharePointURL
                    ExcelFile      = 'Permissions.xlsx'
                    WorksheetName  = 'Folder'
                    NoBatch        = $true
                    NoConfirmation = $true
                }
                $FolderPermission = Import-SharePointExcel @SPPermMailbox
            }
            'CSV' {
                $UserChoice = Import-MailboxCsvDecision -MailboxCSV $MailboxCSV
            }
        }
        $PermissionResult = @{
            SharePointURL     = $SharePointURL
            ExcelFile         = $ExcelFile
            BatchHash         = $BatchHash
            BatchLink         = $BatchLink
            MailboxPermission = $MailboxPermission
            FolderPermission  = $FolderPermission
            IncludeMigrated   = $IncludeMigrated
        }
        $UserChoiceLink = Get-MailboxMovePermissionLinkDecision @PermissionResult -UserChoice $UserChoice
        do {
            $UserChoiceLink = Get-MailboxMovePermissionLinkDecision @PermissionResult -UserChoice $UserChoiceLink
        } until (-not $UserChoiceLink)
    }
}
