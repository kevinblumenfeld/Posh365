function Remove-OktaUser {
    <#
        .SYNOPSIS
            Searches for specific Okta Users and deletes them!

        .DESCRIPTION
            Searches for specific Okta Users and deletes them!

        .PARAMETER SearchString
            Queries firstName, lastName, and email for a match to the -SearchString value specified.
            Partial matches can be searched for.  For example, the search for "J" will Return users with the firstName Joe, John and lastName Hajib

        .PARAMETER ID
            Search by ID

        .EXAMPLE
            Remove-OktaUser -SearchString kevin

        .EXAMPLE
            Remove-OktaUser -Id 00u4m2pk9NMihnsWJ356

        #>
    Param (
        [Parameter()]
        [string] $SearchString,

        [Parameter()]
        [string] $Id
    )

    if ($SearchString -and $Id -or (-not $SearchString -and -not $Id)) {
        Write-Warning "Choose between zero and one parameters only"
        Write-Warning "Please try again"
        break
    }

    $Url = $OKTACredential.GetNetworkCredential().username
    $Token = $OKTACredential.GetNetworkCredential().Password

    $Headers = @{
        "Authorization" = "SSWS $Token"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    }

    if ($SearchString) {
        $SearchResult = (Get-OktaUserReport -SearchString $SearchString).id
        foreach ($CurSearchResult in $SearchResult) {
            $RestSplat = @{
                Uri     = 'https://{0}.okta.com/api/v1/users/{1}?sendEmail=true' -f $Url, $CurSearchResult
                Headers = $Headers
                Method  = 'DELETE'
            }
            do {
                if (($Response.Headers.'x-rate-limit-remaining') -and ($Response.Headers.'x-rate-limit-remaining' -lt 50)) {
                    Start-Sleep -Seconds 4
                }
                $Response = Invoke-WebRequest @RestSplat -Verbose:$false
                $Headers = $Response.Headers
                $User = $Response.Content | ConvertFrom-Json

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
                    Method  = 'DELETE'
                }
            } until (-not $next)
        }

    }
    else {
        $RestSplat = @{
            Uri     = 'https://{0}.okta.com/api/v1/users/{1}?sendEmail=true' -f $Url, $id
            Headers = $Headers
            Method  = 'DELETE'
        }

        do {
            if (($Response.Headers.'x-rate-limit-remaining') -and ($Response.Headers.'x-rate-limit-remaining' -lt 50)) {
                Start-Sleep -Seconds 4
            }
            $Response = Invoke-WebRequest @RestSplat -Verbose:$false
            $Headers = $Response.Headers
            $User = $Response.Content | ConvertFrom-Json

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
                Method  = 'DELETE'
            }

        } until (-not $next)
    }

}
