function Get-MemMobileDevice {
    [CmdletBinding(DefaultParameterSetName = 'PlaceHolder')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'SerialNumber')]
        $SerialNumber,

        [Parameter(Mandatory, ParameterSetName = 'imei')]
        $imei
    )
    if ($imei) {
        Get-MemMobileDeviceData -imei $imei | Select-Object @(
            '*'
        )
    }
    elseif ($SerialNumber) {
        Get-MemMobileDeviceData -SerialNumber $SerialNumber | Select-Object @(
            '*'
        )
    }
    else {
        Get-MemMobileDeviceListData | Select-Object @(
            '*'
        )
    }

}
