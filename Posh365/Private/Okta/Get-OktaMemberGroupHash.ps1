function Get-OktaMemberGroupHash {
    Param (

    )

    $Group = Get-OktaGroupReport
    $Member2Group = @{ }
    foreach ($CurGroup in $Group) {
        $GName = $CurGroup.name
        Start-Sleep -Milliseconds 100
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