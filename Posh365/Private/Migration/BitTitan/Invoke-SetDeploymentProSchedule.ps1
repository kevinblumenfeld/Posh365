function Invoke-SetDeploymentProSchedule {
    [CmdletBinding()]
    Param
    (

    )
    end {
        $Now = [DateTime]::Now
        $ScheduleChoice = Invoke-GetBTUser | Select-Object @(
            'AgentSendStatus'
            'DisplayName'
            'PrimaryEmailAddress'
            'UserPrincipalName'
            @{
                Name       = 'SinceCreated'
                Expression = { '{0:dd}d {0:hh}h {0:mm}m' -f $Now.subtract(($_.Created).ToLocalTime()) }
            }
            @{
                Name       = 'SinceUpdated'
                Expression = { '{0:dd}d {0:hh}h {0:mm}m' -f $Now.subtract(($_.Updated).ToLocalTime()) }
            }
            'FirstName'
            'LastName'
            'Id'
        ) | Out-GridView -Title "DeploymentPro Users" -OutputMode Multiple
        $DateTimeUTC = Get-ScheduleDecision
        $ContinueDecision = Get-ContinueDecision
        Write-Host "Company:" -ForegroundColor Magenta -NoNewline
        Write-Host " $($CustomerId.CompanyName)" -ForegroundColor White
        if ($ContinueDecision) {
            foreach ($Schedule in $ScheduleChoice) {
                try {
                    $ScheduleSplat = @{
                        Ticket                  = $BitTic
                        CustomerId              = $CustomerId.Id
                        ProductSkuId            = '6D8A5E88-2116-497B-874F-38663EF0EBE8'
                        UserPrimaryEmail        = $Schedule.PrimaryEmailAddress
                        DestinationEmailAddress = $Schedule.UserPrincipalName
                        Environment             = 'BT'
                        StartTime               = ($DateTimeUTC).ToString('o')
                        ErrorAction             = 'Stop'
                    }
                    Start-BT_DpUser @ScheduleSplat
                    [PSCustomObject]@{
                        'DisplayName'         = $Schedule.DisplayName
                        'DateTimeUTC'         = $DateTimeUTC
                        'DateTimeLOCAL'       = $DateTimeUTC.ToLocalTime()
                        'PrimaryEmailAddress' = $Schedule.PrimaryEmailAddress
                        'UserPrincipalName'   = $Schedule.UserPrincipalName
                        'Result'              = 'SUCCESS'
                        'Log'                 = 'SUCCESS'
                        'Action'              = 'SCHEDULE'
                        'FirstName'           = $Schedule.FirstName
                        'LastName'            = $Schedule.LastName
                        'Id'                  = $Schedule.Id
                    }
                }
                catch {
                    [PSCustomObject]@{
                        'DisplayName'         = $Schedule.DisplayName
                        'DateTimeUTC'         = $DateTimeUTC
                        'DateTimeLOCAL'       = $DateTimeUTC.ToLocalTime()
                        'PrimaryEmailAddress' = $Schedule.PrimaryEmailAddress
                        'UserPrincipalName'   = $Schedule.UserPrincipalName
                        'Result'              = 'FAILED'
                        'Log'                 = $_.Exception.Message
                        'Action'              = 'SCHEDULE'
                        'FirstName'           = $Schedule.FirstName
                        'LastName'            = $Schedule.LastName
                        'Id'                  = $Schedule.Id
                    }
                }
            }
        }
    }
}
