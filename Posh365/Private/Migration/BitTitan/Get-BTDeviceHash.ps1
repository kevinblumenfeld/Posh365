function Get-BTDeviceHash {
    [CmdletBinding()]
    Param
    (

    )
    end {
        $Script:DeviceHash = @{ }
        $DeviceSplat = @{
            Ticket      = $BitTic
            Environment = 'BT'
            RetrieveAll = $true
            IsDeleted   = $false
        }
        foreach ($Device in Get-BT_CustomerDevice @DeviceSplat ) {
            if (-not $DeviceHash.ContainsKey($Device.Id.ToString())) {
                $DeviceHash.Add($Device.Id.ToString(), @{
                        DeviceName       = $Device.DeviceName
                        OSName           = $Device.OSName
                        Manufacturer     = $Device.Manufacturer
                        Model            = $Device.Model
                        DiskSpaceTotal   = [math]::Round([Double]$Device.DiskSpaceTotal / 1GB, 0)
                        DiskSpaceFree    = [math]::Round([Double]$Device.DiskSpaceFree / 1GB, 0)
                        DomainJoinStatus = $Device.DomainJoinStatus
                    }
                )
            }
        }
    }
}
