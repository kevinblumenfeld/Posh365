function Get-AzureLoadBalancerReport {

    Param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $LB
    )
    begin {

    }
    process {
        $LBArray = [System.Collections.Generic.List[PSCustomObject]]::New()

        foreach ($CurLB in $LB) {

            $LBObj = [ordered]@{
                ResourceGroupName            = $CurLB.ResourceGroupName
                Name                         = $CurLB.Name
                Location                     = $CurLB.Location
                FrontendIpConfigurationsName = $CurLB.FrontendIpConfigurations.name
                BackendAddressPoolsName      = $CurLB.BackendAddressPools.name
            }

            $LBArray.Add($LBObj)

            $LBBackendPoolVMs = $CurLB.BackendAddressPools.BackendIpConfigurations

            if ($LBBackendPoolVMs.count -ne $null) {

                $LBBackendPoolCount = 1
                foreach ($CurLBBackendPoolVMs in $LBBackendPoolVMs) {

                    if (-not $CurLBBackendPoolVMs) {
                        continue
                    }

                    $LBBackendPoolName = "AzureLBBackendPoolVMsID" + $LBBackendPoolCount
                    $LBObj.add($LBBackendPoolName, $CurLBBackendPoolVMs.id)

                    $LBBackendPoolCount++
                    $LBArray.Add($LBObj)
                }
            }
        }
    }
    end {
        $LBArray
    }
}