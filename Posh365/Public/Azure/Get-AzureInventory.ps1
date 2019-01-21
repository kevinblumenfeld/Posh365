function Get-AzureInventory {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [String] $SubID,

        [Parameter(Mandatory)]
        [String] $SubName,

        [Parameter(Mandatory)]
        [String] $ReportPath

    )

    $SubPath = Join-Path $ReportPath $SubName
    if (-not (Test-Path $SubPath)) {
        New-Item -Path $SubPath -ItemType Directory -Force > $null
    }

    Select-AzureRmSubscription -Subscription $SubID

    Write-Host "Collecting data on Azure Virtual Machines (VM)"
    $VM = Get-AzureRmVM
    if ($VM) {
        $VM | Get-AzureVMReport | Export-Csv (Join-Path $SubPath 'Azure_VM_Report.csv') -NoTypeInformation
    }

    Write-Host "Collecting data on Azure Storage Accounts (SA)"
    $StorageAcct = Get-AzureRmStorageAccount
    if ($StorageAcct) {
        $StorageAcct | Get-AzureStorageReport | Export-Csv (Join-Path $SubPath 'Azure_Storage_Report.csv') -NoTypeInformation
    }

    Write-Host "Collecting data on Azure Network Security Groups (NSG)"
    $NSG = Get-AzureRmNetworkSecurityGroup
    if ($NSG) {
        $NSG | Get-AzureNSGReport | Export-Csv (Join-Path $SubPath 'Azure_NSG_Report.csv') -NoTypeInformation
    }

    Write-Host "Collecting data on Azure Load Balancers (LB)"
    $LB = Get-AzureRmLoadBalancer
    if ($LB) {
        $LB | Get-AzureLoadBalancerReport | Export-Csv (Join-Path $SubPath 'Azure_LoadBalancer_Report.csv') -NoTypeInformation
    }

    Write-Host "Collecting data on Azure Virtual Networks (VNet)"
    $VNet = Get-AzureRmVirtualNetwork
    if ($VNet) {
        $VNetData = Get-AzureVNetHelper -VNet $VNet
        $VNetData | Export-Csv (Join-Path $SubPath 'Azure_VNet_Report.csv') -NoTypeInformation
    }

    Write-Host "Collecting data on Azure Traffic Managers (TM)"
    $TrafficMgrProfile = Get-AzureRmTrafficManagerProfile
    $TrafficManager = $TrafficMgrProfile | Get-AzureTrafficManagerReport
    if ($TrafficManager) {
        $TrafficManager | Export-Csv (Join-Path $SubPath "Azure_TrafficManager_Report.csv") -NoTypeInformation
    }

    Write-Host "Collecting data on Azure Traffic Manager Endpoints (TME)"
    $TrafficManagerEndpoint = $TrafficMgrProfile | Get-AzureTrafficManagerEndpointReport
    if ($TrafficManagerEndpoint) {
        $TrafficManagerEndpoint | Export-Csv (Join-Path $SubPath "Azure_TrafficManagerEndPoint_Report.csv") -NoTypeInformation
    }

    $ResourceGroup = Get-AzureRmResourceGroup
    foreach ($CurResourceGroup in $ResourceGroup) {
        $ResGroup = $CurResourceGroup.ResourceGroupName
        $VPNGateway = Get-AzureRmVirtualNetworkGateway -ResourceGroupName $ResGroup

        if ($VPNGateway) {
            Write-Host "Collecting data on Azure Virtual Private Networks (VPN) in Resource Group: $ResGroup"
            $VPNGateway | Get-AzureVPNReport -ResourceGroupName $ResGroup | Export-Csv (Join-Path $SubPath "Azure_VPN_Report_RG_$ResGroup.csv") -NoTypeInformation
        }
    }
}