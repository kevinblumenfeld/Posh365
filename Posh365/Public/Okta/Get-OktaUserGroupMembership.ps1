function Get-OktaUserGroupMembership {
    Param (

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
            Uri     = 'https://{0}.okta.com/api/v1/users/?q={1}' -f $Url, $SearchString
            Headers = $Headers
            Method  = 'Get'
        }

    }
    else {
        $RestSplat = @{
            Uri     = 'https://{0}.okta.com/api/v1/users' -f $Url
            Headers = $Headers
            Method  = 'Get'
        }
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
