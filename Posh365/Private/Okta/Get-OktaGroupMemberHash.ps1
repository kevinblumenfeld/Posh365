function Get-OktaGroupMemberHash {
    Param (
            
    )
    $Url = $OKTACredential.GetNetworkCredential().username
    $Token = $OKTACredential.GetNetworkCredential().Password
    
    $Headers = @{
        "Authorization" = "SSWS $Token"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    }
    
    $RestSplat = @{
        Uri     = "https://$Url.okta.com/api/v1/groups/"
        Headers = $Headers
        method  = 'Get'
    }
            
    $Group = Invoke-RestMethod @RestSplat
    $M2G = @{}
    foreach ($CurGroup in $Group) {
        $GName = $CurGroup.profile.name
        $GId = $CurGroup.id
            
        $RestSplat = @{
            Uri     = "https://$Url.okta.com/api/v1/groups/$GId/users"
            Headers = $Headers
            method  = 'Get'
        }

        $GrpMember = Invoke-RestMethod @RestSplat

        foreach ($CurGrpMember in $GrpMember) {
            $Login = $CurGrpMember.Profile.login
            if (-not $M2G.Contains($Login)) {
                $M2G[$Login] = [system.collections.arraylist]::new()
            }
            $null = $M2G[$Login].Add($GName)
        }
    }
    $M2G
}