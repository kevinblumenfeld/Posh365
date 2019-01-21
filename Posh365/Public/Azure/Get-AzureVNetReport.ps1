function Get-AzureVNetReport {
    param (
        [Parameter(Mandatory)]
        $VNet
    )

    $MaxSubnets = ($VNet.foreach( {$_.Subnets.count}) | Measure-Object -Maximum).Maximum

    $VNet | Get-AzureVNetHelper -MaxSubnets $MaxSubnets

}