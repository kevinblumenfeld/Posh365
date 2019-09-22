function Invoke-GetBTUserTrimmed {
    [CmdletBinding()]
    Param
    (

    )
    end {
        $Now = [DateTime]::Now
        Invoke-GetBTUser | Select-Object @(
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
        )
    }
}
