function Get-MemMobileDevice {
    [CmdletBinding()]
    param (

    )

    Get-MemMobileDeviceData | Select-Object @(
        '*'
    )
}
