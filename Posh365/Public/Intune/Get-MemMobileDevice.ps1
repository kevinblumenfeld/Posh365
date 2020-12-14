function Get-MemMobileDevice {
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
        Get-MemMobileDeviceData -imei $imei | Select-Object @(
            '*'
        )
    }
    elseif ($SerialNumber) {
        Get-MemMobileDeviceData -SerialNumber $SerialNumber | Select-Object @(
            '*'
        )
    }
    elseif ($managementState) {
        Get-MemMobileDeviceData -ManagementState $managementState | Select-Object @(
            '*'
        )
    }
    else {
        Get-MemMobileDeviceListData | Select-Object @(
            '*'
        )
    }

}
