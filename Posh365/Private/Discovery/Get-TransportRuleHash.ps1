function Get-TransportRuleHash {
    param (
        [Parameter(Mandatory)]
        $TransportData
    )

    $TransportHash = @{ }
    foreach ($Transport in $TransportData) {
        $TransportHash.Add($Transport.Guid.ToString() , @{
                'Description' = $Transport.Description
                'Priority'    = $Transport.Priority
                'State'       = $Transport.State
            })
    }
    $TransportHash
}
