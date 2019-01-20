function Get-AzureVPNReport {

    Param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $VPNGateway,

        [Parameter(Mandatory)]
        [string] $ResourceGroupName
    )
    begin {

    }
    process {

        foreach ($CurVpnGateway in $VPNGateway) {
            $id = $CurVpnGateway.IpConfigurations.PublicIPAddress.id
            $PublicIP = (Get-AzureRmPublicIpAddress -ResourceGroup $ResourceGroupName -Name ($id -split '/')[8]).IpAddress

            [PSCustomObject]@{
                ResourceGroupName         = $CurVpnGateway.ResourceGroupName
                Location                  = $CurVpnGateway.Location
                Name                      = $CurVpnGateway.Name
                ProvisioningState         = $CurVpnGateway.ProvisioningState
                GatewayType               = $CurVpnGateway.GatewayType
                VpnType                   = $CurVpnGateway.VpnType
                SkuTier                   = $CurVpnGateway.Sku.Tier
                BgpPeeringAddress         = $CurVpnGateway.BgpSettings.BgpPeeringAddress
                PrivateIpAllocationMethod = $CurVpnGateway.IpConfigurations.PrivateIpAllocationMethod
                PublicIpAddress           = $PublicIP
            }
        }
    }
    end {

    }
}