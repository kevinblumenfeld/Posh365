function Get-OktaUserGroupMembership {
    Param (

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

    $RestSplat = @{
        Uri     = 'https://{0}.okta.com/api/v1/users/?q={1}' -f $url, $SearchString
        Headers = $headers
        method  = 'Get'
    }

    $M2GHash = Get-OktaGroupMemberHash

    $User = Invoke-RestMethod @RestSplat
    
    foreach ($CurUser in $User) {
        $Group = $M2GHash[$CurUser.Profile.Login]
        foreach ($CurGroup in $Group) {
            [PSCustomObject]@{
                FirstName = $CurUser.Profile.FirstName
                LastName  = $CurUser.Profile.LastName
                Login     = $CurUser.Profile.Login
                Email     = $CurUser.Profile.Email
                GroupName = $CurGroup
            }
        }
    }
}
