function Get-GraphMailFolderAll {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]
        $UserPrincipalName
    )
    process {
        foreach ($UPN in $UserPrincipalName) {
            Write-Host "Mailbox: $UPN" -ForegroundColor Green
            if ([datetime]::UtcNow -ge $Script:TimeToRefresh) { Connect-PoshGraphRefresh }
            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/beta/users/{0}/mailfolders/msgfolderroot/childFolders" -f $UPN
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'Get'
            }
            $FolderList = (Invoke-RestMethod @RestSplat -Verbose:$false).value
            foreach ($Folder in $FolderList) {
                [PSCustomObject]@{
                    UserPrincipalName = $UPN
                    DisplayName       = $Folder.DisplayName
                    ChildFolderCount  = $Folder.ChildFolderCount
                    unreadItemCount   = $Folder.unreaditemCount
                    totalItemCount    = $Folder.unreaditemCount
                    wellKnownName     = $Folder.wellKnownName
                    ParentFolderId    = $Folder.ParentFolderId
                    Id                = $Folder.Id
                }
                if ($Folder.ChildFolderCount -ge 1) {
                    $Folder | Get-GraphMailFolderChild -UserPrincipalName $UPN
                }
            }
        }
    }
}
