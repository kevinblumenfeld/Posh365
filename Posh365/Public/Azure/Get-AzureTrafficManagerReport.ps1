function Get-AzureTrafficManagerReport {
    Param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $ResourceGroupName
    )
    begin {

    }
    process {
        $TrafficMgrProfile = Get-AzureRmTrafficManagerProfile

        foreach ($CurTrafficMgrProfile in $TrafficMgrProfile) {

            $TrafficSplat = @{
                ResourceGroupName = $ResourceGroupName
                Name              = $CurTrafficMgrProfile.Endpoints
                Type              = 'AzureEndpoints'
                ProfileName       = $CurTrafficMgrProfile.Name
            }

            $TrafficMgrEndpoint = Get-AzureRmTrafficManagerEndpoint @TrafficSplat
            $TrafficMgrEndpoint.Priority | GM

            [PSCustomObject]@{
                ResourceGroupName      = $CurTrafficMgrProfile.ResourceGroupName
                ProfileName            = $CurTrafficMgrProfile.Name
                ProfileTtl             = $CurTrafficMgrProfile.Ttl
                ProfileStatus          = $CurTrafficMgrProfile.ProfileStatus
                ProfileRoutingMethod   = $CurTrafficMgrProfile.TrafficRoutingMethod
                ProfileMonitorProtocol = $CurTrafficMgrProfile.MonitorProtocol
                ProfileMonitorPort     = $CurTrafficMgrProfile.MonitorPort
                ProfileMonitorPath     = $CurTrafficMgrProfile.MonitorPath
                ProfileMonitorInterval = $CurTrafficMgrProfile.MonitorIntervalInSeconds
                ProfileMonitorTimeout  = $CurTrafficMgrProfile.MonitorTimeoutInSeconds
                ProfileMonitorFailures = $CurTrafficMgrProfile.MonitorToleratedNumberOfFailures
                ProfileEndpoints       = $CurTrafficMgrProfile.Endpoints
                EndpointNamePriority   = $TrafficMgrEndpoint.Priority
            }
        }
    }
    end {

    }
}