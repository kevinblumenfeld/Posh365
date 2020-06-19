function Get-PSGGroup {
    [CmdletBinding()]
    Param
    (

    )
    $GroupList = Get-GSGroup -Filter *

    foreach ($Group in $GroupList) {
        $MemberList = Get-GSGroupMember -Identity $Group.Email
        $OwnerList = $MemberList.where{ $_.Role -eq 'OWNER' }
        $ManagerList = $MemberList.where{ $_.Role -eq 'MANAGER' }
        [PSCustomObject]@{
            Name               = $Group.Name
            Email              = $Group.Email
            Aliases            = @($Group.Aliases) -ne '' -join '|'
            Description        = $Group.Description
            NonEditableAliases = @($Group.NonEditableAliases) -ne '' -join '|'
            MemberCount        = $Group.DirectMembersCount
            Members            = @($MemberList) -ne '' -join '|'
            ManagerCount       = $ManagerList.Count
            Managers           = @($ManagerList) -ne '' -join '|'
            OwnerCount         = $OwnerList.Count
            Owners             = @($OwnerList) -ne '' -join '|'
        }
    }
}