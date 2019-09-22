function Get-DeploymentProStatistics {
    [CmdletBinding()]
    Param
    (
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
    end {
        $OGV = @{
            Title      = 'Choose Users and click OK to Return DeploymentPro Statistics'
            OutputMode = 'Multiple'
        }
        $UserHashSplat = @{
            SkipUserRefresh   = $SkipUserRefresh
            SkipDeviceRefresh = $SkipDeviceRefresh
            AllModules        = $AllModules
        }
        foreach ($User in Invoke-GetBTUserTrimmed | Out-GridView @OGV) {
            $User | Invoke-GetDeploymentProStatistics @UserHashSplat | Out-GridView -Title "DeploymentPro Statistics"
        }
    }
}
