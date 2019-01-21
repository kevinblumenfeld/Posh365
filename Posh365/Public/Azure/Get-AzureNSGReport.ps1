function Get-AzureNSGReport {
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $NSG
    )
    begin {

    }
    process {
        foreach ($CurNSG in $NSG) {

            $NSGRule = $CurNSG.SecurityRules

            if (-not $NSGRule) {
                continue
            }

            foreach ($CurNSGRule in $NSGRule) {
                [PSCustomObject]@{
                    Name                     = $CurNSGRule.Name
                    Priority                 = $CurNSGRule.Priority
                    Protocol                 = $CurNSGRule.Protocol
                    Direction                = $CurNSGRule.Direction
                    SourcePortRange          = ($CurNSGRule.SourcePortRange | Where-Object {$_ -ne $null}) -join ';'
                    DestinationPortRange     = ($CurNSGRule.DestinationPortRange | Where-Object {$_ -ne $null}) -join ';'
                    SourceAddressPrefix      = ($CurNSGRule.SourceAddressPrefix | Where-Object {$_ -ne $null}) -join ';'
                    DestinationAddressPrefix = ($CurNSGRule.DestinationAddressPrefix | Where-Object {$_ -ne $null}) -join ';'
                    Access                   = $CurNSGRule.Access
                }
            }
        }
    }
    end {

    }
}
