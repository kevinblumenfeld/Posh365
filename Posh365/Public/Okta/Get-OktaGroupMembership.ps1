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
        Uri     = 'https://{0}.okta.com/api/v1/groups/{1}/users/?limit=200' -f $Url, $GroupID
        Headers = $Headers
        Method  = 'Get'
    }

    do {
        if (($Response.Headers.'x-rate-limit-remaining') -and ($Response.Headers.'x-rate-limit-remaining' -lt 50)) {
            Start-Sleep -Seconds 4
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
