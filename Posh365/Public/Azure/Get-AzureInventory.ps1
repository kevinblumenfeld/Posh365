function Get-AzureInventory {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [String] $SubID,

        [Parameter(Mandatory)]
        [String] $ReportPath

    )

    $SubPath = Join-Path $ReportPath $SubID
    if (-not (Test-Path $SubPath)) {
        New-Item -Path $SubPath -ItemType Directory -Force > $null
    }

    Select-AzureRmSubscription -Subscription $SubID

    $VM = Get-AzureRmVM
    if ($VM) {
        $VM | Get-AzureVMReport | Export-Csv (Join-Path $SubPath 'Azure_VM_Report.csv') -NoTypeInformation
    }

    $StorageAcct = Get-AzureRmStorageAccount
    if ($StorageAcct) {
        $StorageAcct | Get-AzureStorageReport | Export-Csv (Join-Path $SubPath 'Azure_Storage_Report.csv') -NoTypeInformation
    }

    $NSG = Get-AzureRmNetworkSecurityGroup
    if ($NSG) {
        $NSG | Get-AzureNSGReport | Export-Csv (Join-Path $SubPath 'Azure_NSG_Report.csv') -NoTypeInformation
    }

    $LB = Get-AzureRmLoadBalancer
    if ($LB) {
        $LB | Get-AzureLoadBalancerReport | Export-Csv (Join-Path $SubPath 'Azure_LoadBalancer_Report.csv') -NoTypeInformation
    }

    $VNet = Get-AzureRmVirtualNetwork
    if ($VNet) {
        $VNetData = Get-AzureVNetHelper -VNet $VNet
        $VNetData | Export-Csv (Join-Path $SubPath 'Azure_VNet_Report.csv') -NoTypeInformation
    }

    $ResourceGroup = Get-AzureRmResourceGroup
    foreach ($CurResourceGroup in $ResourceGroup) {
        $ResGroup = $CurResourceGroup.ResourceGroupName
        $VPNGateway = Get-AzureRmVirtualNetworkGateway -ResourceGroupName $ResGroup

        if ($VPNGateway) {
            $VPNGateway | Get-AzureVPNReport -ResourceGroupName $ResGroup | Export-Csv (Join-Path $SubPath "Azure_VPN_Report_RG_$ResGroup.csv") -NoTypeInformation
        }

        $TrafficManager = Get-AzureTrafficManagerReport -ResourceGroupName $ResGroup
        if ($TrafficManager) {
            $TrafficManager | Export-Csv (Join-Path $SubPath "Azure_TrafficManager_Report_RG_$ResGroup.csv") -NoTypeInformation
        }
    }
}