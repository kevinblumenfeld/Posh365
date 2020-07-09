function Get-GraphMailFolder {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $Recurse,

        [Parameter()]
        [ValidateSet('archive', 'clutter', 'conflicts', 'Conversation History', 'ConversationHistory', 'Deleted Items', 'deletedItems', 'drafts', 'inbox', 'junk email', 'junkemail', 'localfailures', 'outbox', 'recoverableitemsdeletions', 'scheduled', 'searchfolders', 'sent items', 'sentitems', 'serverfailures', 'syncissues')]
        [string[]]
        $WellKnownFolder,

        [Parameter(ValueFromPipeline)]
        $UserPrincipalName
    )
    begin {
        if (-not $WellKnownFolder) {
            $WellKnownFolder = @('archive', 'clutter', 'conflicts', 'ConversationHistory'
                'deletedItems', 'drafts', 'inbox', 'junkemail', 'localfailures', 'outbox'
                'recoverableitemsdeletions', 'scheduled', 'searchfolders', 'sentitems'
                'serverfailures', 'syncissues'
            )
        }
        $WellKnown = [System.Collections.Generic.List[string]]::New()
        $WellKnownFolder | ForEach-Object { $WellKnown.Add($_) }
        if ($WellKnown -contains 'deletedItems') {
            $null = $WellKnown.Remove('deletedItems')
            $null = $WellKnown.Add('Deleted Items')
        }
        if ($WellKnown -contains 'sentItems') {
            $null = $WellKnown.Remove('sentitems')
            $null = $WellKnown.Add('Sent Items')
        }
        if ($WellKnown -contains 'junkemail') {
            $null = $WellKnown.Remove('junkemail')
            $null = $WellKnown.Add('junk email')
        }
        if ($WellKnown -contains 'ConversationHistory') {
            $null = $WellKnown.Remove('ConversationHistory')
            $null = $WellKnown.Add('Conversation History')
        }
    }
    process {

        $Script:tree = @{ 'root' = [System.Collections.Generic.List[PSObject]]::new() }

        foreach ($UPN in $UserPrincipalName) {
            Write-Host "`r`nMailbox: $($UPN.UserPrincipalName) " -ForegroundColor Green
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
                        $tree['root'].Add(@{
                                DisplayName       = $UPN.DisplayName
                                Mail              = $UPN.Mail
                                UserPrincipalName = $UPN.UserPrincipalName
                                Folder            = $Folder.DisplayName
                                ChildFolderCount  = $Folder.ChildFolderCount
                                unreadItemCount   = $Folder.unreaditemCount
                                totalItemCount    = $Folder.totalItemCount
                                wellKnownName     = $Folder.wellKnownName
                                ParentFolderId    = 'root'
                                Id                = $Folder.Id
                            })

                        if ($Folder.ChildFolderCount -ge 1 -and $Recurse) {
                            $ChildSplat = @{
                                DisplayName       = $UPN.DisplayName
                                Mail              = $UPN.Mail
                                UserPrincipalName = $UPN.UserPrincipalName
                                Tree              = $tree
                            }
                            $Folder | Get-GraphMailFolderChild @ChildSplat
                        }
                    }
                }
                catch {
                    Write-Host "$($_.Exception)" -ForegroundColor Red -NoNewline
                    break what
                }
            }
        }
        Get-TreePrintout -Tree $tree -id 'root'
    }
    end {

    }
}
