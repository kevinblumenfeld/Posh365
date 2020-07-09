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
            # $R = $Folder.ID.Substring($Folder.ID.Length - 10)
            # $P = $Folder.ParentFolderId.Substring($Folder.ParentFolderId.Length - 10)
            # Write-Host "Inspect for Children: $($Folder.DisplayName) - (ID: $R) Parent: $P " -ForegroundColor yellow

            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/beta/users/{0}/mailFolders/{1}/childFolders" -f $UserPrincipalName, $Folder.Id
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'Get'
            }
            $Children = (Invoke-RestMethod @RestSplat -Verbose:$false).value
            foreach ($Child in $Children) {

                if (-not $tree.ContainsKey($Child.ParentFolderId)) {
                    # Write-Host "Added to tree" -ForegroundColor Green
                    $tree[$Child.ParentFolderId] = [System.Collections.Generic.List[PSObject]]::new()
                }
                [PSCustomObject]@{
                    DisplayName       = $DisplayName
                    Mail              = $Mail
                    UserPrincipalName = $UserPrincipalName
                    Folder            = $Child.DisplayName
                    Path              = $Script:Branch
                    ChildFolderCount  = $Child.ChildFolderCount
                    unreadItemCount   = $Child.unreaditemCount
                    totalItemCount    = $Child.unreaditemCount
                    wellKnownName     = $Child.wellKnownName
                    ParentFolderId    = $Child.ParentFolderId
                    Id                = $Child.Id
                }

                # $R = $Child.ID.Substring($Child.ID.Length - 10)
                # $P = $Child.ParentFolderId.Substring($Child.ParentFolderId.Length - 10)
                # Write-Host "Child Found: $($Child.DisplayName) - (ID: $R) Parent: $P " -ForegroundColor blue -NoNewline

                # else {
                #     Write-Host "NOT Added to tree" -ForegroundColor Red
                # }

                $tree[$Child.ParentFolderId].Add(@{
                        Folder           = $Child.DisplayName
                        Path             = $Script:Branch
                        ChildFolderCount = $Child.ChildFolderCount
                        unreadItemCount  = $Child.unreaditemCount
                        totalItemCount   = $Child.unreaditemCount
                        wellKnownName    = $Child.wellKnownName
                        ParentFolderId   = $Child.ParentFolderId
                        Id               = $Child.Id
                    })

                if ($Child.ChildFolderCount -ge 1) {
                    $ChildSplat = @{
                        DisplayName       = $UPN.DisplayName
                        Mail              = $UPN.Mail
                        UserPrincipalName = $UPN.UserPrincipalName
                        Tree              = $tree
                    }
                    $Child | Get-GraphMailFolderChild @ChildSplat
                }
            }
        }
    }
    end {
        write-Host "$($Script:Branch)" -ForegroundColor Green
    }
}
