function Get-365MsolGroupMember {
    param (

    )

    $Group = Get-MsolGroup -all

    foreach ($CurGroup in $Group) {
        $Member = Get-MsolGroupMember -GroupObjectId $CurGroup.ObjectId -All
        if (-not $CurGroup.LastDirSyncTime) {
            $LastDirSync = 'NotDirSynced'
        }
        else {
            $LastDirSync = ($CurGroup.LastDirSyncTime).ToLocalTime()
        }
        foreach ($CurMember in $Member) {
            [PSCustomObject]@{
                GroupName   = $CurGroup.DisplayName
                LastDirSync = $LastDirSync
                GroupType   = $CurGroup.GroupType
                MemberCount = ($Member).count
                Member      = $CurMember.DisplayName
                MemberEmail = $CurMember.EmailAddress
            }
        }
    }
}
