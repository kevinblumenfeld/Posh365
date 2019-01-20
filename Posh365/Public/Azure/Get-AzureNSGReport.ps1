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
                    SourcePortRange          = ($CurNSGRule | Select-Object @{Name = 'SourcePortRange'; Expression = {$_.SourcePortRange}})
                    DestinationPortRange     = ($CurNSGRule | Select-Object @{Name = 'DestinationPortRange'; Expression = {$_.DestinationPortRange}})
                    SourceAddressPrefix      = ($CurNSGRule | Select-Object @{Name = 'SourceAddressPrefix'; Expression = {$_.SourceAddressPrefix}})
                    DestinationAddressPrefix = ($CurNSGRule | Select-Object @{Name = 'DestinationAddressPrefix'; Expression = {$_.DestinationAddressPrefix}})
                    Access                   = $CurNSGRule.Access
                }
            }
        }
    }
    end {

    }
}
