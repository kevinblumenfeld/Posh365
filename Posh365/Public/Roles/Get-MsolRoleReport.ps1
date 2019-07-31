function Get-MsolRoleReport {
    [CmdletBinding()]
    param (
    )
    Write-Verbose 'Retrieving Msol admin roles'
    $MsolRoleList = Get-MsolRole
    foreach ($MsolRole in $MsolRoleList) {
        Write-Verbose "Processing $($MsolRole.Name)"
        try {
            $RoleMemberList = Get-MsolRoleMember -RoleObjectId $MsolRole.ObjectId -ErrorAction Stop
            foreach ($RoleMember in $RoleMemberList) {
                [PSCustomObject]@{
                    'Role'            = $MsolRole.Name
                    'DisplayName'     = $RoleMember.DisplayName
                    'EmailAddress'    = $RoleMember.EmailAddress
                    'RoleMemberType'  = $RoleMember.RoleMemberType
                    'LastDirSyncTime' = $RoleMember.LastDirSyncTime
                    'MFA_State'       = ($RoleMember.StrongAuthenticationRequirements).State
                    'RoleDescription' = $MsolRole.Description
                }
            }
        }
        catch {

        }


    }
}
