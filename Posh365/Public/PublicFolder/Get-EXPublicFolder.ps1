function Get-EXPublicFolder {
    param (

    )
    end {
        $StatList = Get-PublicFolderStatistics -Resultsize unlimited
        $StatHash = @{ }
        foreach ($Stat in $StatList) {
            $StatHash[$Stat.Identity] = @{
                LastModified = $Stat.LastModificationTime
                Created      = $Stat.CreationTime
                ItemCount    = $Stat.ItemCount
                SizeMB       = [Math]::Round([Double]($Stat.TotalItemSize -replace '^.*\(| .+$|,') / 1MB, 4)
            }
        }

        $FolderList = Get-PublicFolder -Recurse -Resultsize unlimited

        foreach ($Folder in $FolderList) {
            Write-Host "Folder: $($Folder.Name)"
            if ($StatHash[$Folder.EntryID]) {
                [PSCustomObject]@{
                    FolderName   = $Folder.name
                    Identity     = $Folder.Identity
                    FolderType   = $Folder.FolderType
                    LastModified = $StatHash[$Folder.EntryID]['LastModified']
                    Created      = $StatHash[$Folder.EntryID]['Created']
                    ItemCount    = $StatHash[$Folder.EntryID]['ItemCount']
                    SizeMB       = $StatHash[$Folder.EntryID]['SizeMB']
                    MailEnabled  = $Folder.MailEnabled
                    Owner        = ''
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
                    MailEnabled  = $Folder.MailEnabled
                }
            }
        }
    }
}
