function Get-ComplianceRoleReport {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]
        $MFAHash
    )
    $ComplianceRoleList = Get-RoleGroup
    switch ($PSBoundParameters.Keys) {
        $MFAHash {
            foreach ($ComplianceRole in $ComplianceRoleList) {
                Write-Verbose "Processing $($ComplianceRole.DisplayName)"
                $RoleMemberList = Get-RoleGroupMember -Identity $ComplianceRole.Identity
                foreach ($RoleMember in $RoleMemberList) {
                    [PSCustomObject]@{
                        'Role'              = $ComplianceRole.DisplayName
                        'DisplayName'       = $RoleMember.DisplayName
                        'UserPrincipalName' = $MFAHash[$RoleMember.ExternalDirectoryObjectId].UserPrincipalName
                        'IsLicensed'        = $MFAHash[$RoleMember.ExternalDirectoryObjectId].IsLicensed
                        'LastDirSyncTime'   = $MFAHash[$RoleMember.ExternalDirectoryObjectId].LastDirSyncTime
                        'MFA_State'         = $MFAHash[$RoleMember.ExternalDirectoryObjectId].MFA_State
                        'RoleDescription'   = $ComplianceRole.Description
                    }
                }
            }
        }
        Default {
            foreach ($ComplianceRole in $ComplianceRoleList) {
                Write-Verbose "Processing $($ComplianceRole.DisplayName)"
                $RoleMemberList = Get-RoleGroupMember -Identity $ComplianceRole.Identity
                foreach ($RoleMember in $RoleMemberList) {
                    [PSCustomObject]@{
                        'Role'              = $ComplianceRole.DisplayName
                        'DisplayName'       = $RoleMember.DisplayName
                        'UserPrincipalName' = ""
                        'IsLicensed'        = ""
                        'LastDirSyncTime'   = ""
                        'MFA_State'         = ""
                        'RoleDescription'   = $ComplianceRole.Description
                    }
                }
            }
        }
    }

}
