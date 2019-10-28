function Invoke-UpdateMailboxMovePermissionBatch {
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

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $UserInputBatch
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
        $UserChoiceBatchLink = Get-MailboxMovePermissionBatchDecision @PermissionResult -UserChoice $UserChoice -UserInputBatch $UserInputBatch
        do {
            $UserChoiceBatchLink = Get-MailboxMovePermissionBatchDecision @PermissionResult -UserChoice $UserChoiceBatchLink -UserInputBatch $UserInputBatch
        } until (-not $UserChoiceBatchLink)
    }
}
