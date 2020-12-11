function Get-MemMobileDevice {
    [CmdletBinding()]
    param (
    [Parameter()]
    $imei
    )
    if ($imei) {
        Get-MemMobileDeviceData -imei $imei | Select-Object @(
            '*'
        )
    }
    else {
        Get-MemMobileDeviceListData | Select-Object @(
            '*'
        )
    }

}
