function Get-AADMemDevice {
    [cmdletbinding(DefaultParameterSetName = 'PlaceHolder')]
    param (

        [Parameter(Mandatory, ParameterSetName = 'SearchString')]
        $SearchString,

        [Parameter(Mandatory, ParameterSetName = 'ID')]
        $Id,

        [Parameter(Mandatory, ParameterSetName = 'OS')]
        [ValidateSet('IPhone', 'iOS', 'AndroidForWork', 'Windows')]
        $OS,

        [Parameter(Mandatory, ParameterSetName = 'Compliant')]
        [switch]
        $CompliantOnly,

        [Parameter(Mandatory, ParameterSetName = 'NonCompliant')]
        [switch]
        $NonCompliantOnly
    )

    if ($SearchString) {
        Get-AADMemDeviceData -SearchString $SearchString | Select-Object -ExpandProperty Value
    }
    elseif ($Id) {
        Get-AADMemDeviceData -Id $ID
    }
    elseif ($OS) {
        Get-AADMemDeviceData -OS $OS | Select-Object -ExpandProperty Value
    }
    elseif ($CompliantOnly) {
        Get-AADMemDeviceData -CompliantOnly | Select-Object -ExpandProperty Value
    }
    elseif ($NonCompliantOnly) {
        Get-AADMemDeviceData -NonCompliantOnly | Select-Object -ExpandProperty Value
    }
    else {
        Get-AADMemDeviceData | Select-Object -ExpandProperty Value
    }
}
