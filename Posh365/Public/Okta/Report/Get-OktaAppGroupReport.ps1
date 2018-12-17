function Get-OktaAppGroupReport {
    Param (
        [Parameter()]
        [string] $SearchString,

        [Parameter()]
        [string] $Filter,

        [Parameter()]
        [string] $Id
    )
    $Url = $OKTACredential.GetNetworkCredential().username
    $Token = $OKTACredential.GetNetworkCredential().Password

    $Group = Get-OktaGroupReport

    foreach ($CurGroup in $Group) {
        $Id = $CurGroup.Id
        $GName = $CurGroup.Name
        $GDescription = $CurGroup.Description

        $Headers = @{
            "Authorization" = "SSWS $Token"
            "Accept"        = "application/json"
            "Content-Type"  = "application/json"
        }
        $RestSplat = @{
            Uri     = 'https://{0}.okta.com/api/v1/apps?filter=group.id eq "{1}"' -f $Url, $Id
            Headers = $Headers
            Method  = 'Get'
        }

        do {
            if (($Response.Headers.'x-rate-limit-remaining') -and ($Response.Headers.'x-rate-limit-remaining' -lt 50)) {
                Start-Sleep -Seconds 4
            }

            $Response = Invoke-WebRequest @RestSplat -Verbose:$false
            $Headers = $Response.Headers
            $AppsInGroup = $Response.Content | ConvertFrom-Json

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

            foreach ($App in $AppsInGroup) {
                [pscustomobject]@{
                    GroupName     = $GName
                    GroupDesc     = $GDescription
                    GroupId       = $Id
                    AppName       = $App.Name
                    AppLabel      = $App.Label
                    Template      = $App.Credentials.UserNameTemplate.Template
                    Type          = $App.Credentials.UserNameTemplate.Type
                    AppId         = $App.Id
                    AppStatus     = $App.Status
                    AppSignOnMode = $App.SignOnMode
                }
            }
        } until (-not $Next)
    }
}
