function Get-ExchangeRoleReport {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]
        $MFAHash
    )
    $ExchangeRoleList = Get-RoleGroup
    foreach ($ExchangeRole in $ExchangeRoleList) {
        Write-Verbose "Processing $($ExchangeRole.Identity)"
        $RoleMemberList = Get-RoleGroupMember -Identity $ExchangeRole.Identity
        foreach ($RoleMember in $RoleMemberList) {
            [PSCustomObject]@{
                'Role'              = $ExchangeRole.Identity
                'DisplayName'       = $RoleMember.DisplayName
                'UserPrincipalName' = $MFAHash[$RoleMember.ExternalDirectoryObjectId].UserPrincipalName
                'IsLicensed'        = $MFAHash[$RoleMember.ExternalDirectoryObjectId].IsLicensed
                'LastDirSyncTime'   = $MFAHash[$RoleMember.ExternalDirectoryObjectId].LastDirSyncTime
                'MFA_State'         = $MFAHash[$RoleMember.ExternalDirectoryObjectId].MFA_State
                'RoleDescription'   = $ExchangeRole.Description
            }
        }
    }
}
