function Get-AzureNSGReport {
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $NSG
    )
    begin {

    }
    process {
        foreach ($CurNSG in $NSG) {
            $NSGName = $CurNSG.Name
            $NSGNic = ($CurNSG.NetworkInterfaces.Id -replace '.*\/') -Join "`r`n"
            $NSGState = $CurNSG.ProvisioningState
            if ($CurNSG.Tag) {
                $NSGTag = ($CurNSG.Tag.GetEnumerator() | ForEach-Object {$_.key + " " + $_.value}) -Join "`r`n"
            }
            else {
                $NSGTag = $null
            }
            $NSGSubnet = ($CurNSG.Subnets.Id -replace '.*\/') -Join "`r`n"
            $NSGRule = $CurNSG.SecurityRules



            if (-not $NSGRule) {
                continue
            }

            foreach ($CurNSGRule in $NSGRule) {
                [PSCustomObject]@{
                    NSGName                  = $NSGName
                    NSGNic                   = $NSGNic
                    NSGSubnet                = $NSGSubnet
                    NSGState                 = $NSGState
                    NSGTag                   = $NSGTag
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
