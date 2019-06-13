function Get-OktaMemberGroupHash {
    Param (

    )
    $groupId2NameHash = @{ }
    $groupList = Get-OktaGroupReport
    $member2GroupHash = @{ }
    foreach ($Group in $groupList) {
        if (-not $groupId2NameHash.Contains($Group.Id)) {
            $groupId2NameHash[$Group.Id] = $Group.Name
        }
        Start-Sleep -Milliseconds 100
        $memberList = Get-OktaGroupMembership -GroupId $Group.id

        foreach ($Member in $memberList) {

            if (-not $member2GroupHash.Contains($Member.login)) {
                $member2GroupHash[$Member.login] = [system.collections.arraylist]::new()
            }
            $null = $member2GroupHash[$Member.login].Add($Group.Id)
        }
    }
    $Script:groupId2NameHash = $groupId2NameHash
    $member2GroupHash
}