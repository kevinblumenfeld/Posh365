function Get-AzureLoadBalancerHelper {

    Param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $LoadBalancer,

        [Parameter(Mandatory)]
        [int] $MaxBackendPools,

        [Parameter(Mandatory)]
        [int] $MaxFrontendIpConfigs
    )
    begin {

    }
    process {

        foreach ($CurLoadBalancer in $LoadBalancer) {

            $LBObj = [ordered]@{
                Name              = $CurLoadBalancer.Name
                ResourceGroupName = $CurLoadBalancer.ResourceGroupName
                Location          = $CurLoadBalancer.Location
            }

            $BackendPool = $CurLoadBalancer.BackendAddressPools

            foreach ( $Index in 0..($MaxBackendPools - 1) ) {
                $CurBackendPool = $BackendPool[$Index]
                $CurBackendIpConfig = ($CurBackendPool.BackendIpConfigurations.id | Where-Object {$_ -ne $null}) -join "`r`n"
                $PoolName = "BackendPool" + $Index
                $PoolId = "PoolId" + $Index
                $PoolBackendIpConfig = "PoolBackendIpConfig" + $Index

                $LBObj.Add($PoolName, $CurBackendPool.Name)
                $LBObj.Add($PoolId, $CurBackendPool.Id)
                $LBObj.Add($PoolBackendIpConfig, $CurBackendIpConfig)
            }

            $FrontEndIpConfig = $CurLoadBalancer.FrontendIpConfigurations

            foreach ( $Index in 0..($MaxFrontendIpConfigs - 1) ) {
                $CurFrontEndIpConfig = $FrontEndIpConfig[$Index]
                $CurBackendIpConfig = ($CurFrontEndIpConfig.BackendIpConfigurations.id | Where-Object {$_ -ne $null}) -join "`r`n"
                $FEName = "FrontendIpConfigName" + $Index
                $FEId = "FrontendIpConfigId" + $Index
                $PrivateIp = "FrontEndPrivateIp" + $Index
                $PublicIp = "FrontEndPublicIp" + $Index
                $PublicIpId = "FrontEndPublicIpID" + $Index
                $SubnetId = "FrontEndSubnetId" + $Index

                $LBObj.Add($FEName, $CurFrontEndIpConfig.Name)
                $LBObj.Add($PrivateIp, $CurFrontEndIpConfig.PrivateIpAddress)
                $LBObj.Add($PublicIp, $CurFrontEndIpConfig.PublicIpAddress.IpAddress)
                $LBObj.Add($PublicIpId, $CurFrontEndIpConfig.PublicIpAddress.Id)
                $LBObj.Add($SubnetId, $CurFrontEndIpConfig.Subnet.Id)
                $LBObj.Add($FEId, $CurFrontEndIpConfig.Id)
            }

            [PSCustomObject]$LBObj
        }
    }
    end {

    }
}


