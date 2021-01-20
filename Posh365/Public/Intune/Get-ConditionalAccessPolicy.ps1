function Get-ConditionalAccessPolicy {
    param (

    )
    $SPHash = @{ }
    $SPList = Get-AzureADSP
    foreach ($SP in $SPList) {
        $SPHash[$SP.appId] = $SP.displayName
    }
    $RoleHash = @{ }
    $RoleList = Get-GraphUnifiedRole
    foreach ($Role in $RoleList) {
        $RoleHash[$Role.id] = $Role.displayName
    }
    $LocationHash = @{ }
    $LocationList = Get-GraphLocation | Select-Object -ExpandProperty value
    foreach ($Location in $LocationList) {
        $LocationHash[$Location.id] = @{
            displayName = $Location.displayName
            ipRanges    = $Location.ipRanges.cidrAddress
            isTrusted   = $Location.isTrusted
        }
    }
    Get-ConditionalAccessPolicyData | Select-Object @(
        'DisplayName'
        'State'
        @{
            Name       = 'UserRiskLevels'
            Expression = { @($_.Conditions.UserRiskLevels) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'SignInRiskLevels'
            Expression = { @($_.Conditions.SignInRiskLevels) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'ClientAppTypes'
            Expression = { @($_.Conditions.ClientAppTypes) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'includeLocations'
            Expression = { @($_.Conditions.locations.includeLocations.foreach{
                        if ($LocationHash.ContainsKey($_)) {
                            if ($LocationHash[$_]['isTrusted']) { $isTrusted = 'isTrusted:True' } else { $isTrusted = 'isTrusted:False' }
                            $LocName = $LocationHash[$_]['displayName']
                            ($LocationHash[$_]['ipRanges']).foreach{
                                '{0} ({1}) {2}' -f $_, $LocName, $isTrusted
                            }
                        }
                        else { $_ } }) -ne '' -join "`r`n"
            }
        }
        @{
            Name       = 'excludeLocations'
            Expression = { @($_.Conditions.locations.excludeLocations.foreach{
                        if ($LocationHash.ContainsKey($_)) {
                            if ($LocationHash[$_]['isTrusted']) { $isTrusted = 'isTrusted:True' } else { $isTrusted = 'isTrusted:False' }
                            $LocName = $LocationHash[$_]['displayName']
                            ($LocationHash[$_]['ipRanges']).foreach{
                                '{0} ({1}) {2}' -f $_, $LocName, $isTrusted
                            }
                        }
                        else { $_ } }) -ne '' -join "`r`n"
            }
        }
        @{
            Name       = 'includeDeviceStates'
            Expression = { @($_.Conditions.devices.includeDeviceStates) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'excludeDeviceStates'
            Expression = { @($_.Conditions.devices.excludeDeviceStates) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'includeApplications'
            Expression = { @($_.Conditions.applications.includeApplications.foreach{
                        if ($SPHash.ContainsKey($_)) { $SPHash[$_] } else { $_ } }) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'excludeApplications'
            Expression = { @($_.Conditions.applications.excludeApplications.foreach{
                        if ($SPHash.ContainsKey($_)) { $SPHash[$_] } else { $_ } }) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'includeUserActions'
            Expression = { @($_.Conditions.applications.includeUserActions) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'includeUsers'
            Expression = { @($_.Conditions.users.includeUsers.foreach{
                        try { (Get-GraphUser -UserId $_).displayName }
                        catch { } }) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'excludeUsers'
            Expression = { @($_.Conditions.users.excludeUsers.foreach{
                        try { (Get-GraphUser -UserId $_).displayName }
                        catch { } }) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'includeGroups'
            Expression = { @($_.Conditions.users.includeGroups.foreach{
                        try { (Get-GraphGroup -UserId $_).displayName }
                        catch { } }) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'excludeGroups'
            Expression = { @($_.Conditions.users.excludeGroups.foreach{
                        try { (Get-GraphGroup -UserId $_).displayName }
                        catch { } }) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'includeRoles'
            Expression = { @($_.Conditions.users.includeRoles.foreach{
                        if ($RoleHash.ContainsKey($_)) { $RoleHash[$_] } }) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'excludeRoles'
            Expression = { @($_.Conditions.users.excludeRoles.foreach{
                        if ($RoleHash.ContainsKey($_)) { $RoleHash[$_] } }) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'includePlatforms'
            Expression = { @($_.Conditions.platforms.includePlatforms) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'excludePlatforms'
            Expression = { @($_.Conditions.platforms.excludePlatforms) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'operator'
            Expression = { @($_.Grantcontrols.operator) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'builtInControls'
            Expression = { @($_.Grantcontrols.builtInControls) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'persistentBrowser'
            Expression = { @($_.sessioncontrols.persistentBrowser).foreach{ if ($_.isEnabled) { 'mode:{0} persistent isEnabled:{1}' -f $_.mode, $_.isEnabled } } }
        }
        @{
            Name       = 'signInFrequency'
            Expression = { @($_.sessioncontrols.signInFrequency).foreach{ if ($_.isEnabled) { '{0} {1} isEnabled:{2}' -f $_.value, $_.type, $_.isEnabled } } }
        }
        @{
            Name       = 'cloudAppSecurity'
            Expression = { @($_.sessioncontrols.cloudAppSecurity).foreach{ if ($_.isEnabled) { 'cloudAppSecurityType:{0} isEnabled:{1}' -f $_.cloudAppSecurityType, $_.isEnabled } } }
        }
        @{
            Name       = 'applicationEnforcedRestrictions'
            Expression = { @($_.sessioncontrols.applicationEnforcedRestrictions) -ne '' -join "`r`n" }
        }
    )
}
