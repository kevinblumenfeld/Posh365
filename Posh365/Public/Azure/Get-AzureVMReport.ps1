function Get-AzureVMReport {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Microsoft.Azure.Commands.Compute.Models.PSVirtualMachineList[]] $VM
    )
    begin {

    }
    process {
        $VMArray = [System.Collections.Generic.List[PSCustomObject]]::New()
        foreach ($CurVM in $VM) {

            $VMStatus = Get-AzureRmVM -ResourceGroupName $CurVM.ResourceGroupName -Name $CurVM.name -Status

            foreach ($CurNIC in $NIC) {
                if ($CurNIC.Id -eq $CurVM.NetworkProfile.NetworkInterfaces.id) {
                    $PrivateIP = $CurNIC.IpConfigurations.PrivateIPAddress
                }
            }

            $DataDisk = $CurVM.StorageProfile.DataDisks
            $DataDiskName = ''

            foreach ($CurDataDisk in $DataDisk) {
                $CurDataDiskName = $DataDiskName + "; " + $CurDataDisk.name
                $DataDiskName = $CurDataDiskName.Substring(2)
            }

            if ($CurVM.StorageProfile.OSDisk.ManagedDisk -eq $null) {

                $OSDiskUnManaged = $CurVM.StorageProfile.OSDisk.Vhd.Uri
                $OSDiskManaged = "This VM has un-managed OS Disk"

            }
            else {

                $OSDiskManaged = $CurVM.StorageProfile.OSDisk.ManagedDisk.Id
                $OSDiskUnManaged = "This VM has Managed OS Disk"
            }

            [PSCustomObject]@{
                ResourceGroupName  = $CurVM.ResourceGroupName
                VMName             = $CurVM.Name
                VMStatus           = $VMStatus.Statuses[1].DisplayStatus
                Location           = $CurVM.Location
                VMSize             = $CurVM.HardwareProfile.VMSize
                OSDisk             = $CurVM.StorageProfile.OSDisk.OsType
                OSImageType        = $CurVM.StorageProfile.ImageReference.sku
                AdminUserName      = $CurVM.OSProfile.AdminUsername
                NICId              = ($CurVM.NetworkProfile.NetworkInterfaces.id | Where-Object {$_ -ne $null}) -join ';'
                OSVersion          = $CurVM.StorageProfile.ImageReference.Sku
                PrivateIP          = $PrivateIP
                ManagedOSDiskURI   = $OSDiskManaged
                UnManagedOSDiskURI = $OSDiskUnManaged
                DataDiskNames      = $data_disk_name_list
            }

        }
    }
    end {

    }
}