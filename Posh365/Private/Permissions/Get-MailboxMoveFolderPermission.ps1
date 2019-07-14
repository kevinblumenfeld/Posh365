Function Get-MailboxMoveFolderPermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $MailboxList,

        [Parameter(Mandatory = $true)]
        $ADUserList
    )
    end {
        $FolderSelect = @(
            'Object', 'UserPrincipalName', 'PrimarySMTPAddress', 'Folder'
            'AccessRights', 'Granted', 'GrantedUPN', 'GrantedSMTP'
        )

        Write-Verbose "Caching hashtable. DisplayName as Key and Values of UPN, PrimarySMTP, msExchRecipientTypeDetails & msExchRecipientDisplayType"
        $ADHashDisplayName = $ADUserList | Get-ADHashDisplayName -erroraction silentlycontinue

        Write-Verbose "Getting Folder Permissions for each mailbox and writing to file"
        $MailboxList | Get-MailboxFolderPerms -ADHashDisplayName $ADHashDisplayName | Select-Object $FolderSelect
    }
}
