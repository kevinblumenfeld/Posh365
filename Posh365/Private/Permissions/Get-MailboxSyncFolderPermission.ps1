Function Get-MailboxSyncFolderPermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $MailboxList
    )

    $FolderSelect = @(
        'DisplayName', 'PrimarySMTPAddress', 'UserPrincipalName'
        'Folder', 'AccessRights', 'User'
    )

    Write-Verbose "Caching hashtable. DisplayName as Key and Values of UPN, PrimarySMTP, msExchRecipientTypeDetails & msExchRecipientDisplayType"
    $ADHashDisplayName = $MailboxList | Get-ADHashCN

    Write-Verbose "Getting Folder Permissions for each mailbox and writing to file"
    $MailboxList | Get-MailboxFolderPerms -ADHashDisplayName $ADHashDisplayName | Select-Object $FolderSelect

}
