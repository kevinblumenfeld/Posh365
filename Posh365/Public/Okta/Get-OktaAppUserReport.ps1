function Get-OktaAppUserReport {
    Param (
        [Parameter()]
        [string] $SearchString,

        [Parameter()]
        [string] $Filter,

        [Parameter()]
        [string] $Id
    )

    if ($SearchString -and $filter -or ($SearchString -and $Id) -or ($Filter -and $Id)) {
        Write-Warning "Choose between zero and one parameters only"
        Write-Warning "Please try again"
        break
    }

    if (-not $SearchString -and -not $id -and -not $Filter) {
        $User = Get-OktaUserReport
    }
    else {
        if ($SearchString) {
            $User = Get-OktaUserReport -SearchString $SearchString
        }
        if ($Filter) {
            $User = Get-OktaUserReport -Filter $Filter
        }
        if ($Id) {
            $User = Get-OktaUserReport -Id $Id
        }
    }

    $Url = $OKTACredential.GetNetworkCredential().username
    $Token = $OKTACredential.GetNetworkCredential().Password

    foreach ($CurUser in $User) {
        $Id = $CurUser.Id
        $FirstName = $CurUser.FirstName
        $LastName = $CurUser.LastName
        $Login = $CurUser.Login
        $Email = $CurUser.Email
        $Headers = @{
            "Authorization" = "SSWS $Token"
            "Accept"        = "application/json"
            "Content-Type"  = "application/json"
        }
        $RestSplat = @{
            Uri     = 'https://{0}.okta.com/api/v1/apps/?limit=200&filter=user.id+eq+"{1}"' -f $Url, $Id
            Headers = $Headers
            Method  = 'Get'
        }

        do {
            if (($Response.Headers.'x-rate-limit-remaining') -and ($Response.Headers.'x-rate-limit-remaining' -lt 50)) {
                Start-Sleep -Seconds 4
            }
            $Response = Invoke-WebRequest @RestSplat -Verbose:$false
            $Headers = $Response.Headers
            $AppsinUser = $Response.Content | ConvertFrom-Json
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
            foreach ($App in $AppsInUser) {
                [pscustomobject]@{
                    FirstName     = $FirstName
                    LastName      = $LastName
                    Login         = $Login
                    Email         = $Email
                    AppName       = $App.Name
                    AppStatus     = $App.Status
                    AppSignOnMode = $App.SignOnMode
                }
            }
        } until (-not $next)
    }
}
