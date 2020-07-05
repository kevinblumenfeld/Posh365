function Get-GraphMailFolder {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $Recurse,

        [Parameter()]
        [ValidateSet('archive', 'clutter', 'conflicts', 'conversationhistory', 'DeletedItems', 'drafts', 'inbox', 'junkemail', 'localfailures', 'outbox', 'recoverableitemsdeletions', 'scheduled', 'searchfolders', 'sentitems', 'serverfailures', 'syncissues')]
        [string[]]
        $WellKnownFolder,

        [Parameter(ValueFromPipeline)]
        $UserPrincipalName
    )
    process {
        foreach ($UPN in $UserPrincipalName) {
            Write-Host "`r`nMailbox: $($UPN.UserPrincipalName) " -ForegroundColor Green -NoNewline
            foreach ($Known in $WellKnownFolder) {
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
                catch { Write-Host "Not Found" -ForegroundColor Red -NoNewline }
            }
        }
    }
}
