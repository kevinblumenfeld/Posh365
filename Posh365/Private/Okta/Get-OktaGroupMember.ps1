function Get-OktaGroupMember {
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
        Uri     = 'https://{0}.okta.com/api/v1/groups/{1}/users/?limit=200' -f $Url, $GroupID
        Headers = $Headers
        Method  = 'Get'
    }

    do {
        if (($Response.Headers.'x-rate-limit-remaining') -and ($Response.Headers.'x-rate-limit-remaining' -lt 50)) {
            $SleepTime = @{
                Start = ([DateTime]$Response.Headers.Date).ToUniversalTime()
                End   = [DateTimeOffset]::FromUnixTimeSeconds($Response.Headers.'X-Rate-Limit-Reset').DateTime
            }
            Start-Sleep -Seconds (New-TimeSpan @SleepTime).Seconds
            Start-Sleep -Seconds 1
        }
        $Response = Invoke-WebRequest @RestSplat -Verbose:$false
        $Headers = $Response.Headers
        $GrpMember = $Response.Content | ConvertFrom-Json
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

        foreach ($CurGrpMember in $GrpMember) {

            [PSCustomObject]@{
                Login     = $CurGrpMember.Profile.login
                FirstName = $CurGrpMember.Profile.firstName
                LastName  = $CurGrpMember.Profile.lastName
            }

        }
    } until (-not $next)
}
