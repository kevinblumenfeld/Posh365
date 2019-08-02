function Get-TransportRuleHash {
    param (
        [Parameter(Mandatory)]
        $TransportData
    )

    $TransportHash = @{ }
    foreach ($Transport in $TransportData) {
        $TransportHash[$Transport.Guid] = @{
            'Description' = $Transport.Description
            'Priority'    = $Transport.Priority
        }
    }
    $TransportHash
}

