function Get-OktaGroupHash {
    Param (

    )

    $Group = Get-OktaGroupReport
    $GroupHash = @{ }

    foreach ($CurGroup in $Group) {
        $GId = $CurGroup.Id
        $GName = $CurGroup.Name
        $GDescription = $CurGroup.Description
        $GType = $CurGroup.Type
        $Wqdn = $CurGroup.windowsDomainQualifiedName
        $GroupType = $CurGroup.GroupType
        $GroupScope = $CurGroup.GroupScope
        $samAccountName = $CurGroup.samAccountName
        $DistinguishedName = $CurGroup.DistinguishedName
        $Created = $CurGroup.Created
        $LastUpdated = $CurGroup.LastUpdated
        $LastMembershipUpdated = $CurGroup.LastMembershipUpdated

        $GroupHash[$GId] = @{
            Name                       = $GName
            Description                = $GDescription
            Type                       = $GType
            windowsDomainQualifiedName = $Wqdn
            GroupType                  = $GroupType
            GroupScope                 = $GroupScope
            samAccountName             = $samAccountName
            DistinguishedName          = $DistinguishedName
            Created                    = $Created
            LastUpdated                = $LastUpdated
            LastMembershipUpdated      = $LastMembershipUpdated
        }
    }
    $GroupHash
}
