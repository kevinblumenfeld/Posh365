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

    $NameAndId = '{0} ({1})' -f $SubName, [regex]::Matches("$SubID", "(\d+)[^-]*$").value
    $SubPath = Join-Path $ReportPath $NameAndId
    if (-not (Test-Path $SubPath)) {
        New-Item -Path $SubPath -ItemType Directory -Force > $null
    }

    Select-AzureRmSubscription -Subscription $SubID

    Write-Host "Collecting data on Azure Virtual Machines (VM)"
    $VM = Get-AzureRmVM -WarningAction SilentlyContinue
    if ($VM) {
        $VMData = Get-AzureVMReport -VM $VM
        $VMData | Export-Csv (Join-Path $SubPath 'Azure_VM_Report.csv') -NoTypeInformation
    }

    Write-Host "Collecting data on Azure Storage Accounts (SA)"
    $StorageAcct = Get-AzureRmStorageAccount -WarningAction SilentlyContinue
    if ($StorageAcct) {
        $StorageAcct | Get-AzureStorageReport | Export-Csv (Join-Path $SubPath 'Azure_Storage_Report.csv') -NoTypeInformation
    }

    Write-Host "Collecting data on Azure Network Security Groups (NSG)"
    $NSG = Get-AzureRmNetworkSecurityGroup -WarningAction SilentlyContinue
    if ($NSG) {
        $NSG | Get-AzureNSGReport | Export-Csv (Join-Path $SubPath 'Azure_NSG_Report.csv') -NoTypeInformation
    }

    Write-Host "Collecting data on Azure Load Balancers (LB)"
    $LoadBalancer = Get-AzureRmLoadBalancer -WarningAction SilentlyContinue
    if ($LoadBalancer) {
        $LoadBalancerData = Get-AzureLoadBalancerReport -LoadBalancer $LoadBalancer
        $LoadBalancerData | Export-Csv (Join-Path $SubPath 'Azure_LoadBalancer_Report.csv') -NoTypeInformation
    }

    Write-Host "Collecting data on Azure Virtual Networks (VNet)"
    $VNet = Get-AzureRmVirtualNetwork -WarningAction SilentlyContinue

    if ($VNet) {
        $VNetData = Get-AzureVNetReport -VNet $VNet
        $VNetData | Export-Csv (Join-Path $SubPath 'Azure_VNet_Report.csv') -NoTypeInformation
    }

    Write-Host "Collecting data on Azure Traffic Managers (TM)"
    $TrafficMgrProfile = Get-AzureRmTrafficManagerProfile -WarningAction SilentlyContinue
    $TrafficManager = $TrafficMgrProfile | Get-AzureTrafficManagerReport
    if ($TrafficManager) {
        $TrafficManager | Export-Csv (Join-Path $SubPath "Azure_TrafficManager_Report.csv") -NoTypeInformation
    }

    Write-Host "Collecting data on Azure Traffic Manager Endpoints (TME)"
    $TrafficManagerEndpoint = $TrafficMgrProfile | Get-AzureTrafficManagerEndpointReport
    if ($TrafficManagerEndpoint) {
        $TrafficManagerEndpoint | Export-Csv (Join-Path $SubPath "Azure_TrafficManagerEndPoint_Report.csv") -NoTypeInformation
    }

    $AllVPNGateway = [System.Collections.Generic.List[PSCustomObject]]::New()
    $ResourceGroup = Get-AzureRmResourceGroup -WarningAction SilentlyContinue
    foreach ($CurResourceGroup in $ResourceGroup) {
        $ResGroup = $CurResourceGroup.ResourceGroupName
        $VPNGateway = Get-AzureRmVirtualNetworkGateway -ResourceGroupName $ResGroup -WarningAction SilentlyContinue

        if ($VPNGateway) {
            Write-Host "Collecting data on Azure Virtual Private Networks (VPN) in Resource Group: $ResGroup"
            $VPNGateway | Get-AzureVPNReport -ResourceGroupName $ResGroup |
                ForEach-Object { $AllVPNGateway.Add($_) }
        }
    }
    if ($AllVPNGateway) {
        $AllVPNGateway | Export-Csv (Join-Path $SubPath "Azure_VPN_Report.csv") -NoTypeInformation
    }
}