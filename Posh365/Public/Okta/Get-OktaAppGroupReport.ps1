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

    $Headers = @{
        "Authorization" = "SSWS $Token"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    }

    if (-not $Filter -and (-not $SearchString) -and (-not $Id)) {
        $RestSplat = @{
            Uri     = "https://$Url.okta.com/api/v1/groups/"
            Headers = $Headers
            Method  = 'Get'
        }
    }

    if ($id) {
        $RestSplat = @{
            Uri     = 'https://{0}.okta.com/api/v1/groups/?filter=id eq "{1}"' -f $Url, $id
            Headers = $Headers
            Method  = 'Get'
        }
    }

    if ($SearchString) {
        $RestSplat = @{
            Uri     = "https://$Url.okta.com/api/v1/groups/?q=$SearchString"
            Headers = $Headers
            Method  = 'Get'
        }
    }

    $Group = Invoke-RestMethod @RestSplat

    foreach ($CurGroup in $Group) {
        $Id = $CurGroup.Id
        $GName = $CurGroup.Profile.Name
        $GDescription = $CurGroup.Profile.Description
        
        $RestSplat = @{
            Uri     = 'https://{0}.okta.com/api/v1/apps?filter=group.id+eq+"{1}"' -f $Url, $Id
            Headers = $Headers
            Method  = 'Get'
        }

        $AppsInGroup = Invoke-RestMethod @RestSplat

        foreach ($App in $AppsInGroup) {
            [pscustomobject]@{
                GroupName     = $GName
                GroupDesc     = $GDescription
                GroupId       = $CurGroup.Id
                AppName       = $App.Name
                AppStatus     = $App.Status
                AppSignOnMode = $App.SignOnMode
            }
        }
    }
}
