function Get-GraphMailFolder {
    [CmdletBinding()]
    param (

        [Parameter()]
        [ValidateSet('archive', 'clutter', 'conflicts', 'conversationhistory', 'deleteditems', 'drafts', 'inbox', 'junkemail', 'localfailures', 'msgfolderroot', 'outbox', 'recoverableitemsdeletions', 'scheduled', 'searchfolders', 'sentitems', 'serverfailures', 'syncissues')]
        $WellKnownFolder,

        [Parameter(ValueFromPipeline)]
        $MailboxList

    )

    process {
        foreach ($Mailbox in $MailboxList) {
            Write-Host "Mailbox: $($Mailbox.UserPrincipalName)" -ForegroundColor Green
            if ([datetime]::UtcNow -ge $Script:TimeToRefresh) { Connect-PoshGraphRefresh }
            $RestSplat = @{
                Uri     = 'https://graph.microsoft.com/beta/users/{0}/mailFolders/msgfolderroot/childFolders' -f $Mailbox.UserPrincipalName
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'Get'
            }
            $FolderList = (Invoke-RestMethod @RestSplat -Verbose:$true).value
            foreach ($Folder in $FolderList) {
                if ($Folder.wellKnownName) {
                    [PSCustomObject]@{
                        UserPrincipalName = $Mailbox.UserPrincipalName
                        DisplayName       = $Folder.DisplayName
                        ParentFolderId    = $Folder.ParentFolderId
                        ChildFolderCount  = $Folder.ChildFolderCount
                        unreadItemCount   = $Folder.unreaditemCount
                        totalItemCount    = $Folder.unreaditemCount
                        wellKnownName     = $Folder.wellKnownName
                    }
                    if ($Folder.ChildFolderCount -ge 1) {
                        $Folder | Get-GraphMailFolderChild -UserPrincipalName $Mailbox.UserPrincipalName
                    }
                }
            }
        }
    }
}
