function Get-DmarcPolicy {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainData
    )
    $record = $DomainData.DMARC | Where-Object { $_.Strings -like '*v=DMARC1*' } -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Strings -ErrorAction SilentlyContinue

    if ($record -eq $null) { return "N/A" }

    $domainPolicy = $record.Split(';') | Where-Object { $_ -like "* p=*" }

    if ($domainPolicy) {
        $domainPolicy = $domainPolicy.Replace(' ', '')
        $domainPolicy = $domainPolicy.Replace('p=', '')
        $domainPolicy.ToUpper()
    }
}
