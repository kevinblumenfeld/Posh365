function Get-GraphMailFolder {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $Recurse,

        [Parameter()]
        [ValidateSet('archive', 'clutter', 'conflicts', 'conversationhistory', 'Deleted Items', 'drafts', 'inbox', 'junkemail', 'localfailures', 'msgfolderroot', 'outbox', 'recoverableitemsdeletions', 'scheduled', 'searchfolders', 'sentitems', 'serverfailures', 'syncissues')]
        $WellKnownFolder,

        [Parameter(ValueFromPipeline)]
        $MailboxList
    )
    begin {
        # $filterstring = [System.Collections.Generic.List[string]]::new()
        if ($WellKnownFolder) {
            $Uri = "/msgfolderroot/childfolders?`$filter=DisplayName eq '{0}'" -f $WellKnownFolder
        }
        if ($recurse -and -not $WellKnownFolder) {
            $Uri = "/msgfolderroot/childFolders"
        }
    }
    process {
        foreach ($Mailbox in $MailboxList) {
            Write-Host "Mailbox: $($Mailbox.UserPrincipalName)" -ForegroundColor Green
            if ([datetime]::UtcNow -ge $Script:TimeToRefresh) { Connect-PoshGraphRefresh }
            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/beta/users/{0}/mailfolders{1}" -f $Mailbox.UserPrincipalName, $Uri
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'Get'
            }
            $FolderList = (Invoke-RestMethod @RestSplat -Verbose:$false).value
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
                    if ($Folder.ChildFolderCount -ge 1 -and $Recurse) {
                        $Folder | Get-GraphMailFolderChild -UserPrincipalName $Mailbox.UserPrincipalName
                    }
                }
            }
        }
    }
}
