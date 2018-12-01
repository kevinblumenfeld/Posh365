function Get-OktaAppReport {
    Param (
        [Parameter()]
        [string] $GroupId
    )
    $Url = $OKTACredential.GetNetworkCredential().username
    $Token = $OKTACredential.GetNetworkCredential().Password

    $Headers = @{
        "Authorization" = "SSWS $Token"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    }
    if ($GroupId) {
        $RestSplat = @{
            Uri     = 'https://{0}.okta.com/api/v1/apps/?filter=group.id+eq+"{1}"' -f $Url, $GroupId
            Headers = $Headers
            Method  = 'Get'
        }
    }
    else {
        $RestSplat = @{
            Uri     = "https://$Url.okta.com/api/v1/apps/?limit=20"
            Headers = $Headers
            Method  = 'Get'
        }
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
        $App = $Response.Content | ConvertFrom-Json

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

        foreach ($CurApp in $App) {

            $Id = $CurApp.Id
            $Accessibility = ($CurApp).Accessibility
            $Visibility = ($CurApp).Visibility
            $Credentials = ($CurApp).Credentials
            $Features = ($CurApp).Features
            $Settings = ($CurApp).Settings

            [PSCustomObject]@{
                Name                 = $CurApp.Name
                Label                = $CurApp.Label
                Status               = $CurApp.Status
                SignOnMode           = $CurApp.SignOnMode
                TenantType           = $Settings.app.tenantType
                Domain               = $Settings.app.domain
                MsftTenant           = $Settings.app.msftTenant
                CustomDomain         = $Settings.app.customDomain
                FilterGroupsByOU     = $Settings.app.filterGroupsByOU
                Created              = $CurApp.Created
                LastUpdated          = $CurApp.LastUpdated
                Activated            = $CurApp.Activated
                UserNameTemplate     = $Credentials.UserNameTemplate.Template
                UserNameTemplateType = $Credentials.UserNameTemplate.Type
                CredentialScheme     = $Credentials.Scheme
                AppId                = $Id
                Features             = ($Features -join (';'))
            }
        }
    } until (-not $next)
}