function Invoke-RemoveBTUser {
    [CmdletBinding()]
    Param
    (

    )
    end {
        $Now = [DateTime]::Now
        $RemoveChoice = Invoke-GetBTUser | Select-Object @(
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
        ) | Out-GridView -Title "BitTitan Users" -OutputMode Multiple
        $ContinueDecision = Get-ContinueDecision
        if ($ContinueDecision) {
            foreach ($Remove in $RemoveChoice) {
                try {
                    Remove-BT_CustomerEndUser -Ticket $BitTic -id $Remove.Id -Force -ErrorAction Stop
                    [PSCustomObject]@{
                        'DisplayName'         = $Remove.DisplayName
                        'PrimaryEmailAddress' = $Remove.PrimaryEmailAddress
                        'UserPrincipalName'   = $Remove.UserPrincipalName
                        'Result'              = 'SUCCESS'
                        'Log'                 = 'SUCCESS'
                        'Action'              = 'REMOVE'
                        'FirstName'           = $Remove.FirstName
                        'LastName'            = $Remove.LastName
                        'Id'                  = $Remove.Id
                    }
                }
                catch {
                    [PSCustomObject]@{
                        'DisplayName'         = $Remove.DisplayName
                        'PrimaryEmailAddress' = $Remove.PrimaryEmailAddress
                        'UserPrincipalName'   = $Remove.UserPrincipalName
                        'Result'              = 'FAILED'
                        'Log'                 = $_.Exception.Message
                        'Action'              = 'REMOVE'
                        'FirstName'           = $Remove.FirstName
                        'LastName'            = $Remove.LastName
                        'Id'                  = $Remove.Id
                    }
                }
            }
        }
    }
}
