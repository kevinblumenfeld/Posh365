function Get-OktaMemberGroupIDHash {
    Param (

    )
    $Group = Get-OktaGroupReport
    $Member2Group = @{ }
    foreach ($CurGroup in $Group) {
        $GId = $CurGroup.id
        Start-Sleep -Milliseconds 100
        $GrpMember = Get-OktaGroupMembership -GroupId $CurGroup.id

        foreach ($CurGrpMember in $GrpMember) {
            $Login = $CurGrpMember.login
            if (-not $Member2Group.Contains($Login)) {
                $Member2Group[$Login] = [system.collections.arraylist]::new()
            }
            $null = $Member2Group[$Login].Add($GId)
        }
    }
    $Member2Group
}