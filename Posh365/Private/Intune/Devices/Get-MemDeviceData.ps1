function Get-MemDeviceData {
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
    if ([datetime]::UtcNow -ge $TimeToRefresh) { Connect-PoshGraphRefresh }

    if ($imei) {
        $filter = "?`$filter=imei eq '$imei'"
    }
    elseif ($SerialNumber) {
        $filter = "?`$filter=serialNumber eq '$SerialNumber'"
    }
    elseif ($managementState) {
        $filter = "?`$filter=managementState eq '$ManagementState'"
    }
    $RestSplat = @{
        Uri     = "https://graph.microsoft.com/beta/deviceManagement/managedDevices/{0}" -f $filter
        Headers = @{ "Authorization" = "Bearer $Token" }
        Method  = 'Get'
    }
    Invoke-RestMethod @RestSplat -Verbose:$false | Select-Object -ExpandProperty Value

}
