function Test-SPFRecord {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainName
    )
    $Message = Invoke-TestSPFRecord -Domain $DomainName
    $ResultHash = [ordered]@{ }

    if ($message -like "*pass*") {
        $ResultHash.Add('Result', 'PASS')
    }
    else {
        $ResultHash.Add('Result', 'FAIL')
    }
    $Detail = [regex]::Matches($Message, "(?<=Results - )[^<]*").value
    if ($Detail) {
        $ResultHash.Add('Detail', $Detail)
    }
    else {
        $ResultHash.Add('Detail', 'PASS')
    }
    [PSCustomObject]$ResultHash
}
