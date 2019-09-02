function Convert-DistinguishedToCanonical {
    Param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]
        $DistinguishedName
    )
    process {
        foreach ($dn in $DistinguishedName) {
            $d = $dn.Split(',')
            $arr = (@(($d | Where-Object { $_ -notmatch 'DC=' }) | ForEach-Object { $_.Substring(3) }))
            [array]::Reverse($arr)
            "{0}/{1}" -f (($d | Where-Object { $_ -match 'dc=' } | ForEach-Object { $_.Replace('DC=', '') }) -join '.'), ($arr -join '/')
        }
    }
}
