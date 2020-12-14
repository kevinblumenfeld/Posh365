function Get-AADMemMobileDeviceData {
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

    if ([datetime]::UtcNow -ge $TimeToRefresh) { Connect-PoshGraphRefresh }
    if ($Id) {
        $filter = $Id
    }
    elseif ($OS) {
        $filter = "?`$filter=operatingSystem eq '$OS'"
    }
    elseif ($CompliantOnly) {
        $filter = "?`$filter=isCompliant eq true"
    }
    elseif ($NonCompliantOnly) {
        $filter = "?`$filter=isCompliant eq false"
    }
    $RestSplat = @{
        Uri     = "https://graph.microsoft.com/beta/devices/{0}" -f $filter
        Headers = @{ "Authorization" = "Bearer $Token" }
        Method  = 'Get'
    }
    Invoke-RestMethod @RestSplat -Verbose:$false
}
