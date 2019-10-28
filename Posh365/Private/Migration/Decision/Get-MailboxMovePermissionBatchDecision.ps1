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
        if (-not ($PermissionChoice = Get-PermissionDecisionBatch)) {
            break
        }
        if ($PermissionChoice.PSObject.Properties.match('AddToBatch') -and $PermissionChoice.Count -ne 1) {
            do {
                $PermissionChoice = Get-PermissionDecisionBatch
            } until (-not ($PermissionChoice -contains 'AddToBatch' -and $PermissionChoice.Count -gt 1) -or $PermissionChoice -notcontains 'AddToBatch')
        }
        if ($PermissionChoice -contains 'AddToBatch' -and $UserChoice) {
            Update-MailboxMovePermissionBatchHelper -UserChoice $UserChoice -BatchLink $BatchLink -UserInputBatch $UserInputBatch
            break
        }
        if (-not ($DirectionChoice = Get-PermissionDirectionDecision)) {
            break
        }
        $UserChoiceRegex = (@($UserChoice.PrimarySMTPAddress) -ne '' | ForEach-Object { [Regex]::Escape($_) }) -join '|'
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
