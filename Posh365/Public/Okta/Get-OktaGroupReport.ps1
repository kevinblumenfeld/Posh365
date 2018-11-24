function Get-OktaGroupReport {
    Param (
        [Parameter()]
        [String[]]$GroupID,

        [Parameter()]
        [string] $SearchString
            
    )
    $url = $OKTACredential.GetNetworkCredential().username
    $token = $OKTACredential.GetNetworkCredential().Password

    $headers = @{
        "Authorization" = "SSWS $Token"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    }
    if ($SearchString) {
        $RestSplat = @{
            Uri     = 'https://{0}.okta.com/api/v1/groups/?q={1}' -f $url, $SearchString
            Headers = $headers
            method  = 'Get'
        }
    }
    elseif (-not $GroupID) {
        $RestSplat = @{
            Uri     = "https://$URL.okta.com/api/v1/groups/"
            Headers = $headers
            method  = 'Get'
        }
    }
    else {
        $RestSplat = @{
            Uri     = "https://$URL.okta.com/api/v1/groups/$GroupID"
            Headers = $headers
            method  = 'Get'
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
