function Get-AzureVMHelper {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Microsoft.Azure.Commands.Compute.Models.PSVirtualMachineList[]] $VM,

        [Parameter(Mandatory)]
        [int] $MaxDataDisks,

        [Parameter(Mandatory)]
        [int] $MaxOsDisks
    )
    begin {

    }
    process {

        foreach ($CurVM in $VM) {

            $VMStatus = Get-AzureRmVM -ResourceGroupName $CurVM.ResourceGroupName -Name $CurVM.name -Status

            foreach ($CurNIC in $NIC) {
                if ($CurNIC.Id -eq $CurVM.NetworkProfile.NetworkInterfaces.id) {
                    $PrivateIP = $CurNIC.IpConfigurations.PrivateIPAddress
                }
            }

            $DataDisk = $CurVM.StorageProfile.DataDisks
            $OsDisk = $CurVM.StorageProfile.OsDisk

            $VMObj = [ordered]@{
                ResourceGroupName = $CurVM.ResourceGroupName
                VMName            = $CurVM.Name
                VMStatus          = $VMStatus.Statuses[1].DisplayStatus
                Location          = $CurVM.Location
                VMSize            = $CurVM.HardwareProfile.VMSize
                OSDisk            = $CurVM.StorageProfile.OSDisk.OsType
                OSImageType       = $CurVM.StorageProfile.ImageReference.sku
                AdminUserName     = $CurVM.OSProfile.AdminUsername
                NICId             = (($CurVM.NetworkProfile.NetworkInterfaces.id -replace '.*\/') | Where-Object {$_ -ne $null}) -join "`r`n"
                OSVersion         = $CurVM.StorageProfile.ImageReference.Sku
                PrivateIP         = $PrivateIP

            }
            foreach ( $Index in 0..($MaxDataDisks - 1) ) {
                $CurDataDisk = $DataDisk[$Index]
                $DiskName = "DiskName" + $Index
                $DiskSizeGB = "DiskSizeGB" + $Index
                $DiskLun = "DiskLun" + $Index
                $DiskCaching = "DiskCaching" + $Index
                $CreateOption = "DiskCreateOption" + $Index
                $StorageAccountType = "DiskStorageAccountType" + $Index
                $ManagedDisk = "ManagedDisk" + $Index
                $SourceImage = "DDiskSourceImage" + $Index
                $VHD = "DiskVHD" + $Index

                $VMObj.Add($DiskName, $CurDataDisk.Name)
                $VMObj.Add($DiskSizeGB, $CurDataDisk.DiskSizeGB)
                $VMObj.Add($DiskLun, $CurDataDisk.Lun)
                $VMObj.Add($DiskCaching, $CurDataDisk.Caching)
                $VMObj.Add($CreateOption, $CurDataDisk.CreateOption)
                $VMObj.Add($StorageAccountType, $CurDataDisk.ManagedDisk.StorageAccountType)
                $VMObj.Add($ManagedDisk, $CurDataDisk.ManagedDisk.Id -replace '.*\/')
                $VMObj.Add($SourceImage, $CurDataDisk.SourceImage)
                $VMObj.Add($VHD, $CurDataDisk.VirtualHardDisk)

            }
            foreach ( $Index in 0..($MaxOSDisks - 1) ) {
                $CurOsDisk = $OsDisk[$Index]
                $OsDiskName = "OsDiskName" + $Index
                $OsDiskSizeGB = "OsDiskSizeGB" + $Index
                $OsDiskOSType = "OsOSType" + $Index
                $OsDiskCaching = "OsDiskCaching" + $Index
                $OsCreateOption = "OsDiskCreateOption" + $Index
                $OsStorageAccountType = "OsDiskStorageAccountType" + $Index
                $OsManagedDisk = "OsManagedDisk" + $Index
                $OsVHD = "OsDiskVHD" + $Index

                $VMObj.Add($OsDiskName, $CurOsDisk.Name)
                $VMObj.Add($OsDiskSizeGB, $CurOsDisk.DiskSizeGB)
                $VMObj.Add($OsDiskOSType, $CurOsDisk.OSType)
                $VMObj.Add($OsDiskCaching, $CurOsDisk.Caching)
                $VMObj.Add($OsCreateOption, $CurOsDisk.CreateOption)
                $VMObj.Add($OsStorageAccountType, $CurOsDisk.ManagedDisk.StorageAccountType)
                $VMObj.Add($OsManagedDisk, $CurOsDisk.ManagedDisk.Id -replace '.*\/')
                $VMObj.Add($OsVHD, $CurOsDisk.Vhd.Uri)

            }
            [PSCustomObject]$VMObj
        }
    }
    end {

    }
}