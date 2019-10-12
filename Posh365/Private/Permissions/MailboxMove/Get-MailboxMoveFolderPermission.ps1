Function Get-MailboxMoveFolderPermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $MailboxList,

        [Parameter(Mandatory = $true)]
        $ADUserList,

        [parameter()]
        [hashtable]
        $ADHashType,

        [parameter()]
        [hashtable]
        $ADHashDisplay
    )
    end {
        $FolderSelect = @(
            'Object', 'UserPrincipalName', 'PrimarySMTPAddress', 'Folder', 'AccessRights'
            'Granted', 'GrantedUPN', 'GrantedSMTP', 'TypeDetails', 'DisplayType'
        )
        Write-Verbose "Caching hashtable. DisplayName as Key and Values of UPN, PrimarySMTP, msExchRecipientTypeDetails & msExchRecipientDisplayType"
        $ADHashDisplayName = $ADUserList | Get-ADHashDisplayName -erroraction silentlycontinue

        $FolderPermSplat = @{
            ADHashDisplayName = $ADHashDisplayName
            ADHashType        = $ADHashType
            ADHashDisplay     = $ADHashDisplay
            UserGroupHash     = $UserGroupHash
            GroupMemberHash   = $GroupMemberHash

        }
        Write-Verbose "Getting Folder Permissions for each mailbox and writing to file"
        $MailboxList | Get-MailboxFolderPerms @FolderPermSplat | Select-Object $FolderSelect
    }
}
