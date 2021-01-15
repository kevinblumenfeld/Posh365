function Remove-OktaUser {
    <#
        .SYNOPSIS
            Searches for specific Okta Users and FIRST Deactivates them and on a SECOND pass, deletes them!

            IMPORTANT: If you would like to permanently delete the user, you must retain a list of IDs.
                        The process would look like this.
                        1. Obtain a list of IDs that you would like to hard delete.
                        2. Use this function - $IDList | % {Remove-OktaUserReport -Id $_.Id} # This places the user in a deactivated state
                        3. Repeat step #2 - in otherwords it takes takes two Remove-OktaUser to hard delete
            - If you do not have a list of IDs of the Deactivated users, you cannot query for them via the API, Okta has not exposed it
            - In a pinch you could use F12 when loading https://YourOktaTenant.okta.com/admin/users  ## I USED FIREFOX (BELOW) ##
                - The following GET will be displayed https://YourOktaTenant.okta.com/api/internal/people?filter=EVERYONE
                - Right click it and Select COPY > COPY RESPONSE HEADERS
                - You will then be able to use:

                Get-Clipboard | ConvertFrom-Json|Select -expand personlist | ? {$_.status -eq 'Deactivated'} | % {Remove-OktaUser -Id $_.id}

                WARNING!!! THIS WILL REMOVE EVERY SINGLE DEACTIVATED USER and IF YOU ARE NOT CAREFUL YOUR ENTIRE TENANT!!!!!!!!
                BE SURE YOU HAVE TESTED THIS EXTENSIVELY!!!!
                I AM NOT RESPONSIBLE FOR ANY LOSS OR ISSUES!!!

        .DESCRIPTION
            Searches for specific Okta Users and FIRST Deactivates them and on a SECOND pass, deletes them!

            IMPORTANT: If you would like to permanently delete the user, you must retain a list of IDs.
                        The process would look like this.
                        1. Obtain a list of IDs that you would like to hard delete.
                        2. Use this function - $IDList | % {Remove-OktaUserReport -Id $_.Id} # This places the user in a deactivated state
                        3. Repeat step #2 - in otherwords it takes takes two Remove-OktaUser to hard delete
            - If you do not have a list of IDs of the Deactivated users, you cannot query for them via the API, Okta has not exposed it
            - In a pinch you could use F12 when loading https://YourOktaTenant.okta.com/admin/users  ## I USED FIREFOX (BELOW) ##
                - The following GET will be displayed https://YourOktaTenant.okta.com/api/internal/people?filter=EVERYONE
                - Right click it and Select COPY > COPY RESPONSE HEADERS
                - You will then be able to use:

                Get-Clipboard | ConvertFrom-Json|Select -expand personlist | ? {$_.status -eq 'Deactivated'} | % {Remove-OktaUser -Id $_.id}

                WARNING!!! THIS WILL REMOVE EVERY SINGLE DEACTIVATED USER and IF YOU ARE NOT CAREFUL YOUR ENTIRE TENANT!!!!!!!!
                BE SURE YOU HAVE TESTED THIS EXTENSIVELY!!!!
                I AM NOT RESPONSIBLE FOR ANY LOSS OR ISSUES!!!


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
                Uri     = 'https://{0}.okta.com/api/v1/users/{1}' -f $Url, $CurSearchResult
                Headers = $Headers
                Method  = 'DELETE'
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
            Uri     = 'https://{0}.okta.com/api/v1/users/{1}' -f $Url, $id
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
