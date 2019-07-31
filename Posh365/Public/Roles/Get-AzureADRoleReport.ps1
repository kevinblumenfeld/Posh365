function Get-AzureADRoleReport {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]
        $MFAHash
    )
    $AzureADRoleList = Get-AzureADDirectoryRole
    foreach ($AzureADRole in $AzureADRoleList) {
        Write-Verbose "Processing $($AzureADRole.DisplayName)"
        try {
            $RoleMemberList = Get-AzureADDirectoryRoleMember -ObjectId $AzureADRole.ObjectId -ErrorAction Stop
            foreach ($RoleMember in $RoleMemberList) {
                [PSCustomObject]@{
                    'Role'              = $AzureADRole.DisplayName
                    'DisplayName'       = $RoleMember.DisplayName
                    'UserPrincipalName' = $RoleMember.UserPrincipalName
                    'UserType'          = $RoleMember.UserType
                    'LastDirSyncTime'   = $RoleMember.LastDirSyncTime
                    'MFA_State'         = $MFAHash[$RoleMember.UserPrincipalName]
                    'RoleDescription'   = $AzureADRole.Description
                }
            }
        }
        catch {

        }


    }
}
