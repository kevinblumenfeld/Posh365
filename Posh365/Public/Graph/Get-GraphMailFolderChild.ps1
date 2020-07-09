function Get-GraphMailFolderChild {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $UserPrincipalName,

        [Parameter()]
        $Mail,

        [Parameter(Mandatory)]
        $DisplayName,

        [Parameter(ValueFromPipeline)]
        $FolderList,

        [Parameter()]
        $tree
    )
    process {
        foreach ($Folder in $FolderList) {
            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/beta/users/{0}/mailFolders/{1}/childFolders" -f $UserPrincipalName, $Folder.Id
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'Get'
            }
            $Children = (Invoke-RestMethod @RestSplat -Verbose:$false).value
            foreach ($Child in $Children) {
                if (-not $tree.ContainsKey($Child.ParentFolderId)) {
                    $tree[$Child.ParentFolderId] = [System.Collections.Generic.List[PSObject]]::new()
                }
                $tree[$Child.ParentFolderId].Add(@{
                        DisplayName       = $DisplayName
                        Mail              = $Mail
                        UserPrincipalName = $UserPrincipalName
                        Folder            = $Child.DisplayName
                        ChildFolderCount  = $Child.ChildFolderCount
                        unreadItemCount   = $Child.unreaditemCount
                        totalItemCount    = $Child.totalItemCount
                        wellKnownName     = $Child.wellKnownName
                        ParentFolderId    = $Child.ParentFolderId
                        Id                = $Child.Id
                    })

                if ($Child.ChildFolderCount -ge 1) {
                    $ChildSplat = @{
                        DisplayName       = $DisplayName
                        Mail              = $Mail
                        UserPrincipalName = $UserPrincipalName
                        Tree              = $tree
                    }
                    $Child | Get-GraphMailFolderChild @ChildSplat
                }
            }
        }
    }
}
