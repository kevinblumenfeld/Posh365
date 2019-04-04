function Get-OktaAppUserReport {
    <#
        .SYNOPSIS
            Searches for Users assigned to an Okta App

        .DESCRIPTION
            Searches for Users assigned to an Okta App

        .PARAMETER AppID
            Search by App ID

        .EXAMPLE
            Get-OktaAppUserReport -AppId 0oa5if2hrd9LRjCLK356

        #>
    Param (

        [Parameter(Mandatory)]
        [string] $AppId
    )


    $Url = $OKTACredential.GetNetworkCredential().username
    $Token = $OKTACredential.GetNetworkCredential().Password

    $Headers = @{
        "Authorization" = "SSWS $Token"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    }

    $RestSplat = @{
        Uri     = 'https://{0}.okta.com/api/v1/apps/{1}/users?limit=200' -f $Url, $AppID
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
            Method  = 'Get'
        }

        foreach ($CurUser in $User) {
            $ProfileDetail = ($CurUser).Profile
            $CredDetail = ($CurUser).Credentials

            [PSCustomObject]@{
                AppID        = $AppId
                DisplayName  = $ProfileDetail.displayName
                FirstName    = $ProfileDetail.FirstName
                LastName     = $ProfileDetail.LastName
                UserName     = $CredDetail.UserName
                Scope        = $CurUser.Scope
                Status       = $CurUser.Status
                Id           = $CurUser.Id
                SyncState    = $CurUser.SyncState
                Created      = $CurUser.Created
                LastUpdated  = $CurUser.LastUpdated
                StatusChange = $CurUser.StatusChange

            }
        }
    } until (-not $next)
}