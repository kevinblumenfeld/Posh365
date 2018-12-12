function Get-OktaGroupUserMembershipReport {
    Param (
        [Parameter()]
        [string] $SearchString
    )
    $GHash = Get-OktaGroupHash
    $M2GIDHash = Get-OktaMemberGroupIDHash
    $GroupID2Member = Get-OktaGroupMemberHash -Member2Group $M2GIDHash

    foreach ($Entry in $GroupID2Member.GetEnumerator()) {
        $GroupID = $Entry.Key
        $Member = $Entry.Value
        foreach ($CurMember in $Member) {
            [PSCustomObject]@{
                Name           = $GHash.$GroupID.Name
                Member         = $CurMember
                ID             = $GroupID
                Description    = $GHash.$GroupID.Description
                Type           = $GHash.$GroupID.Type
                Wdqn           = $GHash.$GroupID.WindowsQualifiedDistinguishedName
                GroupType      = $GHash.$GroupID.GroupType
                GroupScope     = $GHash.$GroupID.GroupScope
                samAccountName = $GHash.$GroupID.samAccountName
                DN             = $GHash.$GroupID.DistinguishedName
            }
        }
    }
}
