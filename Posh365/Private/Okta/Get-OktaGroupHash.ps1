function Get-OktaGroupHash {
    Param (

    )
    # Just playing with this not used in production
    $Url = $OKTACredential.GetNetworkCredential().username
    $Token = $OKTACredential.GetNetworkCredential().Password

    $Group = Get-OktaGroupReport
    $GroupHash = @{}
    foreach ($CurGroup in $Group) {
        $GName = $CurGroup.Name
        $GId = $CurGroup.Id
        $GDescription = $CurGroup.Description
        $GType = $CurGroup.Type
        $WQDN = $CurGroup.windowsDomainQualifiedName
        $GroupType = $CurGroup.GroupType
        $GroupScope = $CurGroup.GroupScope

        $GroupHash[$GId] = @{
            Login                      = $Login
            FirstName                  = $FirstName
            LastName                   = $LastName
            Name                       = $GName
            Description                = $GDescription
            Type                       = $GType
            windowsDomainQualifiedName = $WQDN
            GroupType                  = $GroupType
            GroupScope                 = $GroupScope
        }
    }
    $GroupHash
}
