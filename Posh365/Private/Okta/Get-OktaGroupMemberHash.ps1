function Get-OktaGroupMemberHash {
    Param (
            
    )
    $url = $OKTACredential.GetNetworkCredential().username
    $token = $OKTACredential.GetNetworkCredential().Password
    
    $headers = @{
        "Authorization" = "SSWS $Token"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    }
    
    $RestSplat = @{
        Uri     = "https://$URL.okta.com/api/v1/groups/"
        Headers = $headers
        method  = 'Get'
    }
            
    $Group = Invoke-RestMethod @RestSplat
    $M2G = @{}
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
            $Login = $CurGrpMember.Profile.login
            if (-not $M2G.Contains($Login)) {
                $M2G[$Login] = [system.collections.arraylist]::new()
            }
            $null = $M2G[$Login].Add($GName)
        }
    }
    $M2G
}