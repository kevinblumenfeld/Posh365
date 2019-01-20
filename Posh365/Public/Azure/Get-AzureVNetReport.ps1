
function Get-AzureVNetReport {
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $VNet,

        [Parameter(Mandatory)]
        [int] $MaxSubnets
    )

    begin {

    }
    process {
        foreach ($CurVNet in $VNet) {

            $VNetObj = [ordered]@{
                ResourceGroupName = $CurVNet.ResourceGroupName
                Location          = $CurVNet.Location
                VNetName          = $CurVNet.Name
                AddressSpace      = ($CurVNet.AddressSpace.AddressPrefixes | Where-Object {$_ -ne $null}) -join ','
            }

            $SubnetVNet = $CurVNet.Subnets

            foreach ( $Index in 0..($MaxSubnets - 1) ) {
                $CurSubnetVNet = $SubnetVNet[$Index]
                $SubnetName = "Subnet" + $Index
                $SubnetAddressSpace = "SubnetAddressSpace" + $Index

                $VNetObj.Add($SubnetName, $CurSubnetVNet.Name)
                $VNetObj.Add($SubnetAddressSpace, $CurSubnetVNet.AddressPrefix)
            }
            [PSCustomObject]$VNetObj
        }
    }
    end {

    }
}



