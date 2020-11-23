function Get-GraphMailFolderAll {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $UserPrincipalName
    )
    process {
        foreach ($UPN in $UserPrincipalName) {
            if ([datetime]::UtcNow -ge $TimeToRefresh) { Connect-PoshGraphRefresh }
            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/beta/users/{0}/mailfolders/msgfolderroot/childFolders" -f $UPN.UserPrincipalName
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'Get'
            }
            try {
                Write-Host "`r`nMailbox: $($UPN.UserPrincipalName) " -ForegroundColor Green -NoNewline
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
                    if ($Folder.ChildFolderCount -ge 1) {
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
