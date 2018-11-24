function Get-OktaGroupReport {
    Param (
        [Parameter()]
        [String[]]$GroupID,

        [Parameter()]
        [string] $SearchString
            
    )
    $Url = $OKTACredential.GetNetworkCredential().username
    $Token = $OKTACredential.GetNetworkCredential().Password

    $Headers = @{
        "Authorization" = "SSWS $Token"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    }
    if ($SearchString) {
        $RestSplat = @{
            Uri     = 'https://{0}.okta.com/api/v1/groups/?q={1}' -f $Url, $SearchString
            Headers = $Headers
            Method  = 'Get'
        }
    }
    elseif (-not $GroupID) {
        $RestSplat = @{
            Uri     = "https://$Url.okta.com/api/v1/groups/"
            Headers = $Headers
            Method  = 'Get'
        }
    }
    else {
        $RestSplat = @{
            Uri     = "https://$Url.okta.com/api/v1/groups/$GroupID"
            Headers = $Headers
            Method  = 'Get'
        }
    }
    

    $Group = Invoke-RestMethod @RestSplat
    
    foreach ($CurGroup in $Group) {
        
        $Profile = $CurGroup.Profile

        [PSCustomObject]@{
            Name                       = $Profile.Name
            Description                = $Profile.Description
            Type                       = $CurGroup.Type
            windowsDomainQualifiedName = $Profile.windowsDomainQualifiedName
            GroupType                  = $Profile.GroupType
            GroupScope                 = $Profile.GroupScope
            samAccountName             = $Profile.samAccountName
            DistinguishedName          = $Profile.DistinguishedName
            Id                         = $CurGroup.Id
            Created                    = $CurGroup.Created
            LastUpdated                = $CurGroup.LastUpdated
            LastMembershipUpdated      = $CurGroup.LastMembershipUpdated
        }
    }
}
