function Invoke-AddX500FromContact {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        $MatchingPrimary
    )
    foreach ($Item in $MatchingPrimary) {
        if ($Item.TargetDisplayName -ne 'NOTFOUND') {
            [PSCustomObject]@{
                TargetDisplayName  = $Item.TargetDisplayName
                SourceDisplayName  = $Item.SourceDisplayName
                TargetType         = $Item.TargetType
                PrimarySmtpAddress = $Item.PrimarySmtpAddress
                LegacyExchangeDN   = $Item.LegacyExchangeDN
                X500               = $Item.X500
                TargetGUID         = $Item.TargetGUID
                TargetIdentity     = $Item.TargetIdentity
                SourceName         = $Item.SourceName
            }
        }
    }
}