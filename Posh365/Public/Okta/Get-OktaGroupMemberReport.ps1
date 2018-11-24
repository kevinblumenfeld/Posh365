function Get-OktaGroupMemberReport {
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
    
    if (-not $GroupID) {
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
        $GName = $CurGroup.profile.name
        $GId = $CurGroup.id
            
        $RestSplat = @{
            Uri     = "https://$Url.okta.com/api/v1/groups/$GId/users"
            Headers = $Headers
            Method  = 'Get'
        }

        $GrpMember = Invoke-RestMethod @RestSplat
        foreach ($CurGrpMember in $GrpMember) {
            [PSCustomObject]@{
                Name      = $GName
                Type      = $CurGroup.Type
                Login     = $CurGrpMember.Profile.login
                FirstName = $CurGrpMember.Profile.firstName
                LastName  = $CurGrpMember.Profile.lastName
                GroupId   = $GId
            }
        }
    }
}