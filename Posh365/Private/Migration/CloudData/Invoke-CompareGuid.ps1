function Invoke-CompareGuid {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]
        $RMHash,

        [Parameter()]
        [hashtable]
        $CloudHash
    )

    foreach ($RMKey in $RMHash.keys) {
        if ($CloudHash.ContainsKey($RMKey)) {
            [PSCustomObject]@{
                Displayname        = if ($RMHash[$RMKey]['DisplayName']) { $RMHash[$RMKey]['DisplayName'] } else { $RMHash[$RMKey]['DisplayName'] }
                OrganizationalUnit = $RMHash[$RMKey]['OrganizationalUnit']
                ExchangeGuidMatch  = $RMHash[$RMKey]['ExchangeGuid'] -eq $CloudHash[$RMKey]['ExchangeGuid']
                ArchiveGuidMatch   = $RMHash[$RMKey]['ArchiveGuid'] -eq $CloudHash[$RMKey]['ArchiveGuid']
                ExchangeGuidOnPrem = $RMHash[$RMKey]['ExchangeGuid']
                ExchangeGuidCloud  = $CloudHash[$RMKey]['ExchangeGuid']
                ArchiveGuidOnPrem  = $RMHash[$RMKey]['ArchiveGuid']
                ArchiveGuidCloud   = $CloudHash[$RMKey]['ArchiveGuid']
                UserPrincipalName =  $RMKey
            }
        }
        else {
            [PSCustomObject]@{
                Displayname        = if ($RMHash[$RMKey]['DisplayName']) { $RMHash[$RMKey]['DisplayName'] } else { $RMHash[$RMKey]['DisplayName'] }
                OrganizationalUnit = $RMHash[$RMKey]['OrganizationalUnit']
                ExchangeGuidMatch  = 'CLOUDUPNNOTFOUND'
                ArchiveGuidMatch   = 'CLOUDUPNNOTFOUND'
                ExchangeGuidOnPrem = $RMHash[$RMKey]['ExchangeGuid']
                ExchangeGuidCloud  = 'CLOUDUPNNOTFOUND'
                ArchiveGuidOnPrem  = $RMHash[$RMKey]['ArchiveGuid']
                ArchiveGuidCloud   = 'CLOUDUPNNOTFOUND'
                UserPrincipalName =  $RMKey
            }
        }
    }
}