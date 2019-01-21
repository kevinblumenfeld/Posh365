
function Get-AzureLoadBalancerReport {
    param (
        [Parameter(Mandatory)]
        $LoadBalancer
    )

    $MaxBackendPools = ($LoadBalancer.foreach( {$_.BackendAddressPools.count}) | Measure-Object -Maximum).Maximum
    $MaxFrontendIpConfigs = ($LoadBalancer.foreach( {$_.FrontendIpConfigurations.count}) | Measure-Object -Maximum).Maximum

    $LoadBalancer | Get-AzureLoadBalancerHelper -MaxBackendPools $MaxBackendPools -MaxFrontendIpConfigs $MaxFrontendIpConfigs

}