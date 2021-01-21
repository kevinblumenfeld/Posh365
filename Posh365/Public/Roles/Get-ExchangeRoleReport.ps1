function Get-ExchangeRoleReport {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]
        $MFAHash
    )
    $ExchangeRoleList = Get-RoleGroup
    switch ($PSBoundParameters.Keys) {
        MFAHash {
            foreach ($ExchangeRole in $ExchangeRoleList) {
                Write-Verbose "Processing $($ExchangeRole.Name)"
                $RoleMemberList = Get-RoleGroupMember -Identity $ExchangeRole.Identity -ResultSize Unlimited
                foreach ($RoleMember in $RoleMemberList) {
                    [PSCustomObject]@{
                        'Role'              = $ExchangeRole.Name
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
        Default {
            foreach ($ExchangeRole in $ExchangeRoleList) {
                Write-Verbose "Processing $($ExchangeRole.Name)"
                $RoleMemberList = Get-RoleGroupMember -Identity $ExchangeRole.Identity -ResultSize Unlimited
                foreach ($RoleMember in $RoleMemberList) {
                    [PSCustomObject]@{
                        'Role'              = $ExchangeRole.Name
                        'DisplayName'       = $RoleMember.DisplayName
                        'UserPrincipalName' = ""
                        'IsLicensed'        = ""
                        'LastDirSyncTime'   = ""
                        'MFA_State'         = ""
                        'RoleDescription'   = $ExchangeRole.Description
                    }
                }
            }
        }
    }

}
