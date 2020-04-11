function Invoke-CompareGuid {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]
        $OnHash,

        [Parameter()]
        [hashtable]
        $CloudHash
    )

    foreach ($OnKey in $OnHash.keys) {
        if ($CloudHash.ContainsKey($OnKey)) {
            [PSCustomObject]@{
                Displayname        = if ($OnHash[$OnKey]['DisplayName']) { $OnHash[$OnKey]['DisplayName'] } else { $OnHash[$OnKey]['DisplayName']}
                OrganizationalUnit = $OnHash[$OnKey]['OrganizationalUnit']
                ExchangeGuidMatch  = $OnHash[$OnKey]['ExchangeGuid'] -eq $CloudHash[$OnKey]['ExchangeGuid']
                ArchiveGuidMatch   = $OnHash[$OnKey]['ArchiveGuid'] -eq $CloudHash[$OnKey]['ArchiveGuid']
                ExchangeGuidOnPrem = $OnHash[$OnKey]['ExchangeGuid']
                ExchangeGuidCloud  = $CloudHash[$OnKey]['ExchangeGuid']
            }
        }
        else {
            [PSCustomObject]@{
                Displayname        = if ($OnHash[$OnKey]['DisplayName']) { $OnHash[$OnKey]['DisplayName'] } else { $OnHash[$OnKey]['DisplayName'] }
                OrganizationalUnit = $OnHash[$OnKey]['OrganizationalUnit']
                ExchangeGuidMatch  = 'CLOUDUPNNOTFOUND'
                ArchiveGuidMatch   = 'CLOUDUPNNOTFOUND'
                ExchangeGuidOnPrem = $OnHash[$OnKey]['ExchangeGuid']
                ExchangeGuidCloud  = 'CLOUDUPNNOTFOUND'
            }
        }
    }
}