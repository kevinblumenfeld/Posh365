function Invoke-GetDeploymentProStatistics {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        $UserList,

        [Parameter()]
        [switch]
        $AllModules,

        [Parameter()]
        [switch]
        $SkipUserRefresh,

        [Parameter()]
        [switch]
        $SkipDeviceRefresh
    )
    begin {
        if (-not $SkipUserRefresh -or -not $UserHash) { Get-BTUserHash }
        if (-not $SkipDeviceRefresh -or -not $DeviceHash) { Get-BTDeviceHash }
        $DevUserSplat = @{
            Ticket      = $BitTic
            Environment = 'BT'
            IsDeleted   = $false
        }
        if (-not $AllModules) { $DevUserSplat.Add('ModuleName', 'OutlookConfigurator') }
    }
    process {
        foreach ($User in $UserList) {
            foreach ($DeviceUser in Get-BT_CustomerDeviceUserModule @DevUserSplat -EndUserId $User.Id) {
                [PSCustomObject]@{
                    DisplayName          = $UserHash.($DeviceUser.EndUserId.ToString()).DisplayName
                    PrimaryEmailAddress  = $UserHash.($DeviceUser.EndUserId.ToString()).PrimaryEmailAddress
                    DeviceName           = $DeviceHash.($DeviceUser.DeviceId.ToString()).DeviceName
                    DiskSpaceFree        = $DeviceHash.($DeviceUser.DeviceId.ToString()).DiskSpaceFree
                    ModuleName           = $DeviceUser.ModuleName
                    State                = $DeviceUser.State
                    ScheduledStartDate   = $DeviceUser.ScheduledStartDate
                    StatusMessage        = $DeviceUser.StatusMessage
                    LatestOutcome        = $DeviceUser.LatestOutcome
                    LatestOutcomeMessage = $DeviceUser.LatestOutcomeMessage
                    FirstName            = $UserHash.($DeviceUser.EndUserId.ToString()).FirstName
                    LastName             = $UserHash.($DeviceUser.EndUserId.ToString()).LastName
                    OSName               = $DeviceHash.($DeviceUser.DeviceId.ToString()).OSName
                    Manufacturer         = $DeviceHash.($DeviceUser.DeviceId.ToString()).Manufacturer
                    Model                = $DeviceHash.($DeviceUser.DeviceId.ToString()).Model
                    DomainJoinStatus     = $DeviceHash.($DeviceUser.DeviceId.ToString()).DomainJoinStatus
                }
            }
        }
    }
    end {

    }
}
