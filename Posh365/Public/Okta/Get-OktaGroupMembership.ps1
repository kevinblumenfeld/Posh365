function Get-OktaGroupMembership {
    Param (
        [Parameter(Mandatory)]
        [string] $GroupId
    )
    $Url = $OKTACredential.GetNetworkCredential().username
    $Token = $OKTACredential.GetNetworkCredential().Password

    $Headers = @{
        "Authorization" = "SSWS $Token"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    }

    $RestSplat = @{
        Uri     = 'https://{0}.okta.com/api/v1/groups/{1}/users?limit=10000' -f $Url, $GroupID
        Headers = $Headers
        Method  = 'Get'
    }

    do {
        [int]$NumberLimit = $Response.Headers.'x-rate-limit-remaining'
        [long][string]$UnixTime = $Response.Headers.'x-rate-limit-reset'

        if ($NumberLimit -and $NumberLimit -eq 1) {
            $ApiTime = $Response.Headers.'Date'
            $SleepTime = Convert-OktaRateLimitToSleep -UnixTime $UnixTime -ApiTime $ApiTime
            Start-Sleep -Seconds $SleepTime
        }
        $Response = Invoke-WebRequest @RestSplat -Verbose:$false
        $Headers = $Response.Headers
        $GroupMember = $Response.Content | ConvertFrom-Json

        if ($Response.Headers['link'] -match '<([^>]+?)>;\s*rel="next"') {
            $Next = $matches[1]
        }
        else {
            $Next = $null
        }
        $Headers = @{
            "Authorization" = "SSWS $Token"
            "Accept"        = "application/json"
            "Content-Type"  = "application/json"
        }
        $RestSplat = @{
            Uri     = $Next
            Headers = $Headers
            Method  = 'Get'
        }

        foreach ($CurGroupMember in $GroupMember) {

            [PSCustomObject]@{
                Login     = $CurGroupMember.Profile.login
                FirstName = $CurGroupMember.Profile.firstName
                LastName  = $CurGroupMember.Profile.lastName
            }

        }
    } until (-not $next)
}
