function Get-OktaUserGroupMembership {
    Param (
        [Parameter()]
        [string] $SearchString
    )

    $M2GHash = Get-OktaMemberGroupHash

    if (-not $SearchString) {
        $User = Get-OktaUserReport
    }
    else {
        $User = Get-OktaUserReport -SearchString $SearchString
    }

    foreach ($CurUser in $User) {
        $Group = $M2GHash[$CurUser.Login]
        foreach ($CurGroup in $Group) {
            [PSCustomObject]@{
                FirstName = $CurUser.FirstName
                LastName  = $CurUser.LastName
                Login     = $CurUser.Login
                Email     = $CurUser.Email
                GroupName = $CurGroup
            }
        }
    }
}
