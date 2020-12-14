function Get-MemMobileDeviceData {
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
        $filter = "imei eq '$imei'"
    }
    elseif ($SerialNumber) {
        $filter = "serialNumber eq '$SerialNumber'"
    }
    elseif ($managementState) {
        $filter = "managementState eq '$ManagementState'"
    }
    $RestSplat = @{
        Uri     = "https://graph.microsoft.com/beta/deviceManagement/managedDevices/?`$filter={0}" -f $filter
        Headers = @{ "Authorization" = "Bearer $Token" }
        Method  = 'Get'
    }
    Invoke-RestMethod @RestSplat -Verbose:$false | Select-Object -ExpandProperty Value

}
