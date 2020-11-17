function Get-MailboxMovePermissionBatchDecision {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $SharePointURL,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ExcelFile,

        [Parameter()]
        $BatchHash,

        [Parameter()]
        $BatchLink,

        [Parameter()]
        $MailboxPermission,

        [Parameter()]
        $FolderPermission,

        [Parameter()]
        [psobject]
        $UserChoice,

        [Parameter()]
        [switch]
        $IncludeMigrated,

        [Parameter()]
        $UserInputBatch
    )
    end {
        if (-not $UserChoice) {
            break
        }
        if (-not $UserChoice.PrimarySMTPAddress) {
            break
        }
        if ($PermissionChoice = Get-PermissionDecisionBatch) {
            if ($PermissionChoice.Options.Contains('AddToBatch') -and $PermissionChoice.Options.Count -ne 1 ) {
                do {
                    $PermissionChoice = Get-PermissionDecisionBatch
                } until ($PermissionChoice.Options.Contains('AddToBatch') -and $PermissionChoice.Options.Count -eq 1 -or
                    -not $PermissionChoice.Options.Contains('AddToBatch') -and $PermissionChoice.Options.Count -gt 0)
            }
            if ($PermissionChoice.Options.Contains('AddToBatch') -and $PermissionChoice.Options.Count -eq 1) {
                $ReportPath = [Environment]::GetFolderPath("Desktop")
                Update-MailboxMovePermissionBatchHelper -UserChoice $UserChoice -BatchLink $BatchLink -UserInputBatch $UserInputBatch |
                Export-Csv -Path (Join-Path $ReportPath Batches.csv) -NoTypeInformation

                $ExcelSplat = @{
                    Path                    = (Join-Path $ReportPath 'Batches.xlsx')
                    TableStyle              = 'Medium2'
                    FreezeTopRowFirstColumn = $true
                    AutoSize                = $true
                    BoldTopRow              = $true
                    ClearSheet              = $true
                    WorksheetName           = 'Batches'
                    ErrorAction             = 'stop'
                }
                try {
                    $BatchesFile = Join-Path $ReportPath 'Batches.csv'
                    $BatchesFile | Where-Object { $_ } | ForEach-Object { Import-Csv $_ | Export-Excel @ExcelSplat }
                }
                catch {
                    $_.Exception.Message
                }
                break
            }
        }

        if (-not ($DirectionChoice = Get-PermissionDirectionDecision)) {
            break
        }
        $UserChoiceRegex = '^(?:{0})$' -f ((@($UserChoice.PrimarySMTPAddress) -ne '' | ForEach-Object { [Regex]::Escape($_) }) -join '|')
        $PermissionResult = @{
            SharePointURL     = $SharePointURL
            ExcelFile         = $ExcelFile
            UserChoiceRegex   = $UserChoiceRegex
            PermissionChoice  = $PermissionChoice
            DirectionChoice   = $DirectionChoice
            BatchHash         = $BatchHash
            BatchLink         = $BatchLink
            MailboxPermission = $MailboxPermission
            FolderPermission  = $FolderPermission
        }
        $LinkResults = Get-MailboxMovePermissionLinkResult @PermissionResult

        $UCSet = [System.Collections.Generic.HashSet[string]]::new()
        ($LinkResults | Out-GridView -OutputMode Multiple -Title "Choose Objects (Left Side)") | Select-Object PrimarySMTPAddress | ForEach-Object {
            $Null = $UCSet.Add($_.PrimarySmtpAddress)
        }
        ($LinkResults | Out-GridView -OutputMode Multiple -Title "Choose Granted (Right Side)") | Select-Object GrantedSMTP | ForEach-Object {
            $Null = $UCSet.Add($_.GrantedSMTP)
        }
        $UCSet | ForEach-Object {
            [PSCustomObject]@{
                PrimarySmtpAddress = $_
            }
        }
    }
}
