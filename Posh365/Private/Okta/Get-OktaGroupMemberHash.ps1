function Get-OktaGroupMemberHash {
    Param (

        [Parameter(Mandatory)]
        [hashtable] $Member2Group

    )
    $Group2Member = @{ }
    foreach ($Entry in $Member2Group.GetEnumerator()) {
        $User = $Entry.Key
        foreach ($Group in $Entry.Value) {
            if (-not $Group2Member.ContainsKey($Group)) {
                $Group2Member[$Group] = [System.Collections.Generic.List[string]]::new()
            }
            $Group2Member[$Group].Add($User)
        }
    }
    $Group2Member
}