Function Get-UniqueString {
    param(
        [Parameter(Mandatory = $true)]
        $searchStrings
    )

    $suffixes = " .*
_E3
_E5
_P1
_P2
_P3
_1
_2
2
_GOV
_MIDMARKET
_STUDENT
_FACULTY
_A
_O365" -split "`r`n"
    $sthash = @{}
    $uniques = @()
    foreach ($searchString in $searchStrings) {
        $ss = $searchString
        foreach ($suffix in $suffixes) {
            $searchString = $searchString -replace "$suffix$", "REPLACED"
        }
        $uniques += $searchString -replace "REPLACED"
        if (!($sthash.ContainsKey($uniques[(($uniques.count) - 1)]))) {
            $sthash.($uniques[(($uniques.count) - 1)]) = $ss
        }
    }
    # $uniques | Select -Unique
    $sthash
}
