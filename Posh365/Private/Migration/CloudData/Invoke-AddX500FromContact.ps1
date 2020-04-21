function Invoke-AddX500FromContact {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        $MatchingPrimary
    )
    $AllFound = $MatchingPrimary.where{ $_.Found }
    $Count = $AllFound.Count
    $i = 0
    foreach ($Item in $AllFound) {
        $i++
        [PSCustomObject]@{
            Count              = '[{0} of {1}]' -f $i, $Count
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