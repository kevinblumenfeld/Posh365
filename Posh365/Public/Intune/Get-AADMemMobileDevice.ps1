function Get-AADMemMobileDevice {
    [cmdletbinding(DefaultParameterSetName = 'PlaceHolder')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'ID')]
        $Id,

        [Parameter(Mandatory, ParameterSetName = 'OS')]
        [ValidateSet('iOS', 'AndroidForWork', 'Windows')]
        $OS,

        [Parameter(Mandatory, ParameterSetName = 'Compliant')]
        [switch]
        $CompliantOnly,

        [Parameter(Mandatory, ParameterSetName = 'NonCompliant')]
        [switch]
        $NonCompliantOnly
    )
    if ($Id) {
        Get-AADMemMobileDeviceData -Id $ID
    }
    elseif ($OS) {
        Get-AADMemMobileDeviceData -OS $OS | Select-Object -ExpandProperty Value
    }
    elseif ($CompliantOnly) {
        Get-AADMemMobileDeviceData -CompliantOnly | Select-Object -ExpandProperty Value
    }
    elseif ($NonCompliantOnly) {
        Get-AADMemMobileDeviceData -NonCompliantOnly | Select-Object -ExpandProperty Value
    }
    else {
        Get-AADMemMobileDeviceData | Select-Object -ExpandProperty Value
    }
}
