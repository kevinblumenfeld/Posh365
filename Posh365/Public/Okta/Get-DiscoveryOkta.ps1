function Get-DiscoveryOkta {
    <#
    .SYNOPSIS
    Runs the Okta Discovery Scripts

    .DESCRIPTION
    Runs the Okta Discovery Scripts

    .PARAMETER Tenant
    The name that describes the tenant..
    for example: Contoso  could be used for contoso.okta.com

    .PARAMETER ReportPath
    Where the reports should be saved. There will be a folder created if it doesnt already exist
    Under this folder a folder named the "tenant" will also be created.  Here you will find the reports.

    .EXAMPLE
    Get-DiscoveryOkta -Tenant Contoso -ReportPath C:\Scripts\Okta -Verbose

    .NOTES
    Use the verbose switch to see progress
    #>
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
    $OktaUserApp = (Join-Path $TenantPath "$Tenant-Okta_UserApp.csv")
    $OktaAppGroup = (Join-Path $TenantPath "$Tenant-Okta_AppGroup.csv")
    $OktaPolicy = (Join-Path $TenantPath "$Tenant-Policy.csv")

    Write-Verbose "Discovering`tOKTA Users"
    Get-OktaUserReport | Export-Csv $OktaUser -NoTypeInformation -Encoding UTF8

    Write-Verbose "Discovering`tOKTA User Group Membership"
    Get-OktaUserGroupMembershipReport | Export-Csv $OktaUserGroupMembership -NoTypeInformation -Encoding UTF8

    Write-Verbose "Discovering`tOKTA Groups"
    Get-OktaGroupReport | Export-Csv $OktaGroup -NoTypeInformation -Encoding UTF8

    Write-Verbose "Discovering`tOKTA Group Members"
    Get-OktaGroupMemberReport | Export-Csv $OktaGroupMember -NoTypeInformation -Encoding UTF8

    Write-Verbose "Discovering`tOKTA Apps"
    Get-OktaAppReport | Export-Csv $OktaApp -NoTypeInformation -Encoding UTF8

    Write-Verbose "Discovering`tOKTA Users Assigned To Apps"
    Get-OktaUserAppReport | Export-Csv $OktaUserApp -NoTypeInformation -Encoding UTF8

    Write-Verbose "Discovering`tOKTA Groups Assigned To Apps"
    Get-OktaAppGroupReport | Export-Csv $OktaAppGroup -NoTypeInformation -Encoding UTF8

    Write-Verbose "Discovering`tOKTA Policies"
    Get-OktaPolicyReport | Export-Csv $OktaPolicy -NoTypeInformation -Encoding UTF8
}
