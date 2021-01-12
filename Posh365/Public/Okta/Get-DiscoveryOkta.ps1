function Get-DiscoveryOkta {
    <#
    .SYNOPSIS
    Runs the Okta Discovery Scripts

    .DESCRIPTION
    Runs the Okta Discovery Scripts

    .PARAMETER Tenant
    The name that describes the tenant..
    for example: Contoso  could be used for contoso.okta.com

    .EXAMPLE
    Get-DiscoveryOkta -Tenant Contoso -Verbose

    .NOTES
    Use the verbose switch to see progress
    #>
    Param (
        [Parameter(Mandatory)]
        [string] $Tenant
    )

    $PoshPath = Join-Path ([Environment]::GetFolderPath("Desktop")) -ChildPath 'Posh365'
    $DiscoPath = Join-Path $PoshPath -ChildPath 'Discovery'
    $TenantPath = Join-Path $DiscoPath -ChildPath $Tenant
    $Detailed = Join-Path $TenantPath -ChildPath 'Okta'

    $null = New-Item -ItemType Directory -Path $DiscoPath  -ErrorAction SilentlyContinue
    $null = New-Item -ItemType Directory -Path $TenantPath  -ErrorAction SilentlyContinue
    $null = New-Item -ItemType Directory -Path $Detailed  -ErrorAction SilentlyContinue

    $OktaUser = (Join-Path $Detailed "Okta_User.csv")
    $OktaUserGroupMembership = (Join-Path $Detailed "Okta_UserGroupMembership.csv")
    $OktaGroup = (Join-Path $Detailed "Okta_Group.csv")
    $OktaGroupMember = (Join-Path $Detailed "Okta_GroupMember.csv")
    $OktaApp = (Join-Path $Detailed "Okta_App.csv")
    $OktaUserApp = (Join-Path $Detailed "Okta_UserApp.csv")
    $OktaAppGroup = (Join-Path $Detailed "Okta_AppGroup.csv")
    $OktaPolicy = (Join-Path $Detailed "Policy.csv")

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

    $ExcelSplat = @{
        Path                    = (Join-Path $TenantPath 'Okta_Discovery.xlsx')
        TableStyle              = 'Medium2'
        FreezeTopRowFirstColumn = $true
        AutoSize                = $true
        BoldTopRow              = $false
        ClearSheet              = $true
        ErrorAction             = 'SilentlyContinue'
    }
    Get-ChildItem $Detailed -Filter "*.csv" | Sort-Object BaseName -Descending |
    ForEach-Object { Import-Csv $_.fullname | Export-Excel @ExcelSplat -WorksheetName $_.basename }

    # Complete
    Write-Verbose "Script Complete"
    Write-Host ("Results can be found on Desktop here: {0}" -f $ExcelSplat['Path']) -ForegroundColor Green
}
