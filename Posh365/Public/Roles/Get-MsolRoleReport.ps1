function Get-MsolRoleReport {
    [CmdletBinding()]
    param (

    )
    Write-Verbose "Retrieving Azure AD admin roles"
    $MsolRoleList = @(Get-MsolRole -ErrorAction Stop)
    foreach ($MsolRole in $MsolRoleList) {
        Write-Verbose "Processing $($MsolRole.DisplayName)"
        $RoleMemberList = Get-MsolRoleMember -RoleObjectId $MsolRole.ObjectId
        foreach ($RoleMember in $RoleMemberList) {
            [PSCustomObject]@{
                "Role"              = $MsolRole.Name
                "Display Name"      = $RoleMember.DisplayName
                "EmailAddress"      = $RoleMember.EmailAddress
                "RoleMemberType"    = $RoleMember.RoleMemberType
                "LastDirSyncTime"   = $RoleMember.LastDirSyncTime
                "Password Policies" = $RoleMember.PasswordPolicies
                "StrongAuthReq"     = @($_.StrongAuthenticationRequirements) -join '|'
                "Description"       = $MsolRole.Description
                "IsEnabled"         = $MsolRole.IsEnabled
            }
        }
    }
}
