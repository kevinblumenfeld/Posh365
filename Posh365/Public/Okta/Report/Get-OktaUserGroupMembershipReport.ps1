function Get-OktaUserGroupMembershipReport {
    Param (
        [Parameter()]
        [string] $SearchString,

        [Parameter()]
        [string] $Login,

        [Parameter()]
        [switch] $RefreshGroupMemberHash
    )

    if ($RefreshGroupMemberHash -or -not $M2GHash -or -not $groupId2NameHash) {
        $M2GHash = Get-OktaMemberGroupHash
        $Script:M2GHash = $M2GHash
    }

    if ($SearchString) {
        $userList = Get-OktaUserReport -SearchString $SearchString
    }
    elseif ($Login) {
        $userList = Get-OktaUserReport -Login $Login
    }
    else {
        $userList = Get-OktaUserReport
    }

    foreach ($User in $userList) {
        $groupList = $M2GHash[$User.Login]
        foreach ($Group in $groupList) {
            [PSCustomObject]@{
                GroupName = $groupId2NameHash.$Group
                GroupId   = $Group
                FirstName = $User.FirstName
                LastName  = $User.LastName
                Login     = $User.Login
                Email     = $User.Email
            }
        }
    }
}
