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

        $Script:Branch = ('{0} > {1}' -f $Prefix, $item.Folder)

        if ($tree.$($Item.Id).Count -gt 0) {
            Get-TreePrintout -tree $tree -Id $Item.Id -prefix ('{0} > {1}' -f $Prefix, $item.Folder)
        }
    }
}

