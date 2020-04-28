function Invoke-CompareGuid {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]
        $RMHash,

        [Parameter()]
        [hashtable]
        $CloudHash,

        [Parameter()]
        $Numbered
    )

    if ($Numbered) {
        $i = 0
        $Count = $Numbered.Count
        foreach ($Num in $Numbered) {
            $i++
            [PSCustomObject]@{
                Count              = '[{0} of {1}]' -f $i, $Count
                DisplayName        = $Num.DisplayName
                OrganizationalUnit = $Num.OrganizationalUnit
                ExchangeGuidMatch  = $Num.ExchangeGuidMatch
                ArchiveGuidMatch   = $Num.ArchiveGuidMatch
                ExchangeGuidOnPrem = $Num.ExchangeGuidOnPrem
                ExchangeGuidCloud  = $Num.ExchangeGuidCloud
                ArchiveGuidOnPrem  = $Num.ArchiveGuidOnPrem
                ArchiveGuidCloud   = $Num.ArchiveGuidCloud
                UserPrincipalName  = $Num.UserPrincipalName
            }
        }
    }
    else {
        foreach ($RMKey in $RMHash.keys) {
            if ($CloudHash.ContainsKey($RMKey)) {
                [PSCustomObject]@{
                    Displayname           = if ($RMHash[$RMKey]['DisplayName']) { $RMHash[$RMKey]['DisplayName'] } else { $RMHash[$RMKey]['DisplayName'] }
                    UserPrincipalName     = $RMKey
                    PrimarySmtpAddress    = $RMHash[$RMKey]['PrimarySmtpAddress']
                    OrganizationalUnit    = $RMHash[$RMKey]['OrganizationalUnit']
                    ExchangeGuidMatch     = $RMHash[$RMKey]['ExchangeGuid'] -eq $CloudHash[$RMKey]['ExchangeGuid']
                    ArchiveGuidMatch      = $RMHash[$RMKey]['ArchiveGuid'] -eq $CloudHash[$RMKey]['ArchiveGuid']
                    ExchangeGuidOnPrem    = $RMHash[$RMKey]['ExchangeGuid']
                    ExchangeGuidCloud     = $CloudHash[$RMKey]['ExchangeGuid']
                    ArchiveGuidOnPrem     = $RMHash[$RMKey]['ArchiveGuid']
                    ArchiveGuidCloud      = $CloudHash[$RMKey]['ArchiveGuid']
                    EmailCount            = $RMHash[$RMKey]['EmailCount']
                    AllEmailAddresses     = $RMHash[$RMKey]['AllEmailAddresses']
                    EmailAddresses        = $RMHash[$RMKey]['EmailAddresses']
                    EmailAddressesNotSmtp = $RMHash[$RMKey]['EmailAddressesNotSmtp']
                }
            }
            else {
                [PSCustomObject]@{
                    Displayname           = if ($RMHash[$RMKey]['DisplayName']) { $RMHash[$RMKey]['DisplayName'] } else { $RMHash[$RMKey]['DisplayName'] }
                    UserPrincipalName     = $RMKey
                    PrimarySmtpAddress    = $RMHash[$RMKey]['PrimarySmtpAddress']
                    OrganizationalUnit    = $RMHash[$RMKey]['OrganizationalUnit']
                    ExchangeGuidMatch     = 'CLOUDUPNNOTFOUND'
                    ArchiveGuidMatch      = 'CLOUDUPNNOTFOUND'
                    ExchangeGuidOnPrem    = $RMHash[$RMKey]['ExchangeGuid']
                    ExchangeGuidCloud     = 'CLOUDUPNNOTFOUND'
                    ArchiveGuidOnPrem     = $RMHash[$RMKey]['ArchiveGuid']
                    ArchiveGuidCloud      = 'CLOUDUPNNOTFOUND'
                    EmailCount            = $RMHash[$RMKey]['EmailCount']
                    AllEmailAddresses     = $RMHash[$RMKey]['AllEmailAddresses']
                    EmailAddresses        = $RMHash[$RMKey]['EmailAddresses']
                    EmailAddressesNotSmtp = $RMHash[$RMKey]['EmailAddressesNotSmtp']
                }
            }
        }
    }
}