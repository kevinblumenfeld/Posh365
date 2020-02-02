function Get-TransportRuleHash {
    param (
        [Parameter(Mandatory)]
        $TransportData
    )

    $TransportHash = @{ }
    foreach ($Transport in $TransportData) {
        $TransportHash.Add($Transport.Name.ToString() , @{
                'Description' = $Transport.Description
                'Priority'    = $Transport.Priority
                'State'       = $Transport.State
            })
    }
    $TransportHash
}
