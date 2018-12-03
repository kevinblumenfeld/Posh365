function Get-OktaGroupMemberHash {
    Param (

    )
    # Just playing with this.. not production ready.  Needs array of hashtables (for users)
    $Url = $OKTACredential.GetNetworkCredential().username
    $Token = $OKTACredential.GetNetworkCredential().Password

    $Group = Get-OktaGroupReport
    $Group2Member = @{}
    foreach ($CurGroup in $Group) {
        $GroupName = $CurGroup.Name
        $GroupId = $CurGroup.Id
        $GroupDescription = $CurGroup.Description
        $GType = $CurGroup.Type
        $Wqdn = $CurGroup.windowsDomainQualifiedName
        $GroupType = $CurGroup.GroupType
        $GroupScope = $CurGroup.GroupScope

        $GroupMember = Get-OktaGroupMembership -GroupId $GroupId

        foreach ($CurGroupMember in $GroupMember) {
            $Login = $CurGroupMember.Login
            $FirstName = $CurGroupMember.FirstName
            $LastName = $CurGroupMember.LastName
            $Group2Member[$GroupId] = @{
                Login                      = $Login
                FirstName                  = $FirstName
                LastName                   = $LastName
                Name                       = $GroupName
                Description                = $GroupDescription
                Type                       = $GType
                windowsDomainQualifiedName = $Wqdn
                GroupType                  = $GroupType
                GroupScope                 = $GroupScope

            }
        }
    }
    $Group2Member
}