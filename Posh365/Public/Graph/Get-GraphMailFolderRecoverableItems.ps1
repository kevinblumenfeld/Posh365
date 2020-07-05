function Get-GraphMailFolderRecoverableItems {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $UserPrincipalName
    )
    process {
        foreach ($UPN in $UserPrincipalName) {
            if ([datetime]::UtcNow -ge $Script:TimeToRefresh) { Connect-PoshGraphRefresh }
            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/beta/users/{0}/mailfolders/root/childFolders?`$top=1000" -f $UPN.UserPrincipalName
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'Get'
            }
            try {
                Write-Host "`r`nMailbox (RecoverableItems): $($UPN.UserPrincipalName) " -ForegroundColor Green -NoNewline
                $FolderList = ((Invoke-RestMethod @RestSplat -Verbose:$false).value).where{ $_.wellKnownName -like 'RecoverableItems*' }
                # $FolderList = (Invoke-RestMethod @RestSplat -Verbose:$false).value
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
            catch { Write-Host "Not Found $($_.Exception)" -ForegroundColor Red -NoNewline }
        }
    }
}
