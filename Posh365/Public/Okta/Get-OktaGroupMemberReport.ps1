function Get-OktaGroupMemberReport {
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
        $GName = $CurGroup.profile.name
        $GId = $CurGroup.id
            
        $RestSplat = @{
            Uri     = "https://$URL.okta.com/api/v1/groups/$GId/users"
            Headers = $headers
            method  = 'Get'
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