
function Get-MailboxMoveFolderResult {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $DirectionChoice,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $FolderPermission
    )
    end {
        $OrElements = foreach ($Direction in $DirectionChoice.Options) {
            if ($Direction -match 'delegates') {
                '$_.Userprincipalname -match $UserChoiceRegex'
            }

            if ($Direction -match 'delegated') {
                '$_.GrantedUPN -match $UserChoiceRegex'
            }
        }
        $AndElements = '$_.AccessRights -ne "AvailabilityOnly"'
        $Filter = [ScriptBlock]::Create((($OrElements -join ' -or '), $AndElements -join ' -and '))
        foreach ($Permission in $FolderPermission) {
            $Permission | Where-Object $Filter
        }
    }
}
