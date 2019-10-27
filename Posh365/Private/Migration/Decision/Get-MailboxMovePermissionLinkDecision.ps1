function Get-MailboxMovePermissionLinkDecision {
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
        $IncludeMigrated
    )
    end {
        if (-not $UserChoice) {
            break
        }
        if (-not $UserChoice.PrimarySMTPAddress) {
            break
        }
        if (-not ($PermissionChoice = Get-PermissionDecision)) {
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
