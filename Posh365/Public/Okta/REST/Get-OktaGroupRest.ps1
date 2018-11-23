function Get-OktaGroupRest {
    Param (
        [Parameter()]
        [String[]]$GroupID
    )
    $url = $Credential.GetNetworkCredential().username
    $token = $Credential.GetNetworkCredential().Password

    $headers = @{
        "Authorization" = "SSWS $Token"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    }
    
    if (-not $GroupID) {
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
