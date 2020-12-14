function Get-MemDevice {
    [CmdletBinding(DefaultParameterSetName = 'PlaceHolder')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'SerialNumber')]
        $SerialNumber,

        [Parameter(Mandatory, ParameterSetName = 'imei')]
        $imei,

        [Parameter(Mandatory, ParameterSetName = 'ManagementState')]
        [ValidateSet('retirePending', 'managed')]
        $managementState
    )
    if ($imei) {
        Get-MemDeviceData -imei $imei | Select-Object @(
            '*'
        )
    }
    elseif ($SerialNumber) {
        Get-MemDeviceData -SerialNumber $SerialNumber | Select-Object @(
            '*'
        )
    }
    elseif ($managementState) {
        Get-MemDeviceData -ManagementState $managementState | Select-Object @(
            '*'
        )
    }
    else {
        Get-MemMobileDeviceListData | Select-Object @(
            '*'
        )
    }

}
