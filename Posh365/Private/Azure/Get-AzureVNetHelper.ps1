
function Get-AzureVNetHelper {
    param (
        [Parameter(Mandatory)]
        $VNet
    )

    $MaxSubnets = ($VNet.foreach( {$_.Subnets.count}) | Measure-Object -Maximum).Maximum

    $VNet | Get-AzureVNetReport -MaxSubnets $MaxSubnets

}



