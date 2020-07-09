function Get-TreePrintout {
    [CmdletBinding()]
    param (
        [Parameter()]
        $tree,

        [Parameter()]
        $Id,

        [Parameter()]
        $prefix
    )
    foreach ($item in $tree.$Id) {

        # $Path = ('{0} > {1}' -f $Prefix, $item.Folder)
        [PSCustomObject]@{
            DisplayName       = $Item.DisplayName
            Mail              = $Item.Mail
            UserPrincipalName = $Item.UserPrincipalName
            Folder            = $Item.Folder
            Path              = '{0} > {1}' -f $Prefix, $item.Folder
            ChildFolderCount  = $Item.ChildFolderCount
            unreadItemCount   = $Item.unreaditemCount
            totalItemCount    = $Item.totalItemCount
            wellKnownName     = $Item.wellKnownName
            ParentFolderId    = $Item.ParentFolderId
            Id                = $Item.Id
        }

        if ($tree.$($Item.Id).Count -gt 0) {
            Get-TreePrintout -tree $tree -Id $Item.Id -prefix ('{0} > {1}' -f $Prefix, $item.Folder)
        }
    }
}

