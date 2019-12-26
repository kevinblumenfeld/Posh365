function Get-DmarcSubdomainPolicy {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainData
    )
    $record = $DomainData.DMARC | Where-Object { $_.Strings -like '*v=DMARC1*' } -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Strings -ErrorAction SilentlyContinue

    if ($record -eq $null) { return "N/A" }

    $subDomainPolicy = $record.Split(';') | Where-Object { $_ -like "*sp=*" }

    if ($subDomainPolicy) {
        $subDomainPolicy = $subDomainPolicy.Replace(' ', '')
        $subDomainPolicy = $subDomainPolicy.Replace('sp=', '')
        $subDomainPolicy.ToUpper()
    }
}
