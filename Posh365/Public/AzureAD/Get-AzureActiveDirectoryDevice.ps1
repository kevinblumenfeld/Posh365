function Get-AzureActiveDirectoryDevice {
    param (

    )
    Get-AzureADDevice -All:$true | Select-Object @(
        'DeviceOSType'
        'DisplayName'
        'DeviceOSVersion'
        'DeviceTrustType'
        @{
            Name       = 'DirSyncEnabled'
            Expression = { [bool]$_.DirSyncEnabled }
        }
        'ApproximateLastLogonTimeStamp'
        'LastDirSyncTime'

        @{
            Name       = 'isManaged'
            Expression = { [bool]$_.isManaged }
        }


        @{
            Name       = 'isCompliant'
            Expression = { [bool]$_.isCompliant }
        }
        'ProfileType'
        'DeviceId'
    )
}
