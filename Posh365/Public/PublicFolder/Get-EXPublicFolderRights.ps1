function Get-EXPublicFolderRights {
    param (

    )
    end {
        $StatHash = @{ }
        $StatList = Get-PublicFolderStatistics -Resultsize unlimited

        foreach ($Stat in $StatList) {
            $StatHash[$Stat.Identity] = @{
                LastModified = $Stat.LastModificationTime
                Created      = $Stat.CreationTime
                ItemCount    = $Stat.ItemCount
                SizeMB       = [Math]::Round([Double]($Stat.TotalItemSize -replace '^.*\(| .+$|,') / 1MB, 4)
            }
        }

        $FolderList = Get-PublicFolder -Recurse -Resultsize Unlimited

        foreach ($Folder in $FolderList) {
            Write-Host "Folder: $($Folder.Name)"
            $PermList = Get-PublicFolderClientPermission -Identity $Folder.EntryID
            if ($PermList) {
                foreach ($Perm in $PermList) {

                    if ($StatHash[$Folder.EntryID]) {
                        [PSCustomObject]@{
                            FolderName   = $Folder.name
                            Identity     = $Folder.Identity
                            FolderType   = $Folder.FolderType
                            LastModified = $StatHash[$Folder.EntryID]['LastModified']
                            Created      = $StatHash[$Folder.EntryID]['Created']
                            ItemCount    = $StatHash[$Folder.EntryID]['ItemCount']
                            SizeMB       = $StatHash[$Folder.EntryID]['SizeMB']
                            User         = [regex]::Matches("$($Perm.User)", "[^/]*$").value[0]
                            AccessRights = @($Perm.AccessRights) -ne '' -join '|'
                            MailEnabled  = $Folder.MailEnabled
                        }
                    }
                    else {
                        [PSCustomObject]@{
                            FolderName   = $Folder.name
                            Identity     = $Folder.Identity
                            FolderType   = $Folder.FolderType
                            LastModified = ''
                            Created      = ''
                            ItemCount    = ''
                            SizeMB       = ''
                            User         = [regex]::Matches("$($Perm.User)", "[^/]*$").value[0]
                            AccessRights = @($Perm.AccessRights) -ne '' -join '|'
                            MailEnabled  = $Folder.MailEnabled
                        }
                    }
                }
            }
            else {
                if ($StatHash[$Folder.EntryID]) {
                    [PSCustomObject]@{
                        FolderName   = $Folder.name
                        Identity     = $Folder.Identity
                        FolderType   = $Folder.FolderType
                        LastModified = $StatHash[$Folder.EntryID]['LastModified']
                        Created      = $StatHash[$Folder.EntryID]['Created']
                        ItemCount    = $StatHash[$Folder.EntryID]['ItemCount']
                        SizeMB       = $StatHash[$Folder.EntryID]['SizeMB']
                        User         = ''
                        AccessRights = ''
                        MailEnabled  = $Folder.MailEnabled
                    }
                }
                else {
                    [PSCustomObject]@{
                        FolderName   = $Folder.name
                        Identity     = $Folder.Identity
                        FolderType   = $Folder.FolderType
                        LastModified = ''
                        Created      = ''
                        ItemCount    = ''
                        SizeMB       = ''
                        User         = ''
                        AccessRights = ''
                        MailEnabled  = $Folder.MailEnabled
                    }
                }
            }
        }
    }
}
