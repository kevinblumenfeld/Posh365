function Get-OktaMemberGroupHash {
    Param (

    )
    $Url = $OKTACredential.GetNetworkCredential().username
    $Token = $OKTACredential.GetNetworkCredential().Password

    $Group = Get-OktaGroupReport
    $Member2Group = @{}
    foreach ($CurGroup in $Group) {
        $GName = $CurGroup.name

        $GrpMember = Get-OktaGroupMembership -GroupId $CurGroup.id

        foreach ($CurGrpMember in $GrpMember) {
            $Login = $CurGrpMember.login
            if (-not $Member2Group.Contains($Login)) {
                $Member2Group[$Login] = [system.collections.arraylist]::new()
            }
            $null = $Member2Group[$Login].Add($GName)
        }
    }
    $Member2Group
}