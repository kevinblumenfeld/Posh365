function Get-OktaDiscovery {
    Param (

        [Parameter(Mandatory)]
        [string] $Tenant,

        [Parameter(Mandatory)]
        [string] $ReportPath

    )

    $TenantPath = Join-Path -Path $ReportPath -ChildPath $Tenant

    if (-not (Test-Path $TenantPath)) {
        New-Item -ItemType Directory -Force -Path $TenantPath
    }

    $OktaUser = (Join-Path $TenantPath "$Tenant-Okta_User.csv")
    $OktaUserGroupMembership = (Join-Path $TenantPath "$Tenant-Okta_UserGroupMembership.csv")
    $OktaGroup = (Join-Path $TenantPath "$Tenant-Okta_Group.csv")
    $OktaGroupMember = (Join-Path $TenantPath "$Tenant-Okta_GroupMember.csv")
    $OktaApp = (Join-Path $TenantPath "$Tenant-Okta_App.csv")
    $OktaAppUser = (Join-Path $TenantPath "$Tenant-Okta_AppUser.csv")
    $OktaAppGroup = (Join-Path $TenantPath "$Tenant-Okta_AppGroup.csv")
    $OktaPolicy = (Join-Path $TenantPath "$Tenant-Policy.csv")

    Write-Verbose "Discovering`tOKTA Users"
    Get-OktaUserReport | Export-Csv $OktaUser -NoTypeInformation -Encoding UTF8

    Write-Verbose "Discovering`tOKTA User Group Membership"
    Get-OktaUserGroupMembership | Export-Csv $OktaUserGroupMembership -NoTypeInformation -Encoding UTF8

    Write-Verbose "Discovering`tOKTA Groups"
    Get-OktaGroupReport | Export-Csv $OktaGroup -NoTypeInformation -Encoding UTF8

    Write-Verbose "Discovering`tOKTA Group Members"
    Get-OktaGroupMemberReport | Export-Csv $OktaGroupMember -NoTypeInformation -Encoding UTF8

    Write-Verbose "Discovering`tOKTA Apps"
    Get-OktaAppReport | Export-Csv $OktaApp -NoTypeInformation -Encoding UTF8

    Write-Verbose "Discovering`tOKTA Users Assigned To Apps"
    Get-OktaAppUserReport | Export-Csv $OktaAppUser -NoTypeInformation -Encoding UTF8

    Write-Verbose "Discovering`tOKTA Groups Assigned To Apps"
    Get-OktaAppGroupReport | Export-Csv $OktaAppGroup -NoTypeInformation -Encoding UTF8

    Write-Verbose "Discovering`tOKTA Policies"
    Get-OktaPolicyReport | Export-Csv $OktaPolicy -NoTypeInformation -Encoding UTF8
}
