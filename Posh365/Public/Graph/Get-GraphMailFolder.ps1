function Get-GraphMailFolder {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $Recurse,

        [Parameter()]
        [ValidateSet('archive', 'clutter', 'conflicts', 'Conversation History', 'ConversationHistory', 'Deleted Items', 'deletedItems', 'drafts', 'inbox', 'junk email', 'junkemail', 'localfailures', 'outbox', 'recoverableitemsdeletions', 'scheduled', 'searchfolders', 'sentitems', 'serverfailures', 'syncissues')]
        [string[]]
        $WellKnownFolder,

        [Parameter(ValueFromPipeline)]
        $UserPrincipalName
    )
    begin {
        $WellKnown = [System.Collections.Generic.List[string]]::New()
        $WellKnownFolder | ForEach-Object { $WellKnown.Add($_) }
        if ($WellKnown -contains 'deleteditems') {
            $WellKnown.Remove('deletedItems')
            $WellKnown.Add('Deleted Items')
        }
        if ($WellKnown -contains 'junkemail') {
            $WellKnown.Remove('junkemail')
            $WellKnown.Add('junk email')
        }
        if ($WellKnown -contains 'conversationhistory') {
            $WellKnown.Remove('conversationhistory')
            $WellKnown.Add('Conversation History')
        }
    }
    process {
        foreach ($UPN in $UserPrincipalName) {
            Write-Host "`r`nMailbox: $($UPN.UserPrincipalName) " -ForegroundColor Green -NoNewline
            :what foreach ($Known in $WellKnown) {
                if ([datetime]::UtcNow -ge $Script:TimeToRefresh) { Connect-PoshGraphRefresh }
                $Uri = "/msgfolderroot/childfolders?`$filter=DisplayName eq '{0}'" -f $Known
                $RestSplat = @{
                    Uri     = "https://graph.microsoft.com/beta/users/{0}/mailfolders{1}" -f $UPN.UserPrincipalName, $Uri
                    Headers = @{ "Authorization" = "Bearer $Token" }
                    Method  = 'Get'
                }
                try {
                    $FolderList = (Invoke-RestMethod @RestSplat -Verbose:$false).value
                    foreach ($Folder in $FolderList) {
                        [PSCustomObject]@{
                            DisplayName       = $UPN.DisplayName
                            Mail              = $UPN.Mail
                            UserPrincipalName = $UPN.UserPrincipalName
                            Folder            = $Folder.DisplayName
                            ChildFolderCount  = $Folder.ChildFolderCount
                            unreadItemCount   = $Folder.unreaditemCount
                            totalItemCount    = $Folder.unreaditemCount
                            wellKnownName     = $Folder.wellKnownName
                            ParentFolderId    = $Folder.ParentFolderId
                            Id                = $Folder.Id
                        }
                        if ($Folder.ChildFolderCount -ge 1 -and $Recurse) {
                            $ChildSplat = @{
                                DisplayName       = $UPN.DisplayName
                                Mail              = $UPN.Mail
                                UserPrincipalName = $UPN.UserPrincipalName
                            }
                            $Folder | Get-GraphMailFolderChild @ChildSplat
                        }
                    }
                }
                catch {
                    Write-Host "Not Found" -ForegroundColor Red -NoNewline
                    break what
                }
            }
        }
    }
}
