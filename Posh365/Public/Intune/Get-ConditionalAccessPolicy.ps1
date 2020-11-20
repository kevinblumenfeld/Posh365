function Get-ConditionalAccessPolicy {
    param (

    )
    $SPHash = @{ }
    $SPList = Get-AzureADServicePrincipal
    foreach ($SP in $SPList) {
        $SPHash[$SP.appId] = $SP.displayName
    }
    $RoleHash = @{ }
    $RoleList = Get-AzureADServicePrincipal
    foreach ($Role in $RoleList) {
        $RoleHash[$Role.appId] = $Role.displayName
    }
    $LocationHash = @{ }
    $LocationList = Get-GraphLocation | Select-Object -ExpandProperty value
    foreach ($Location in $LocationList) {
        $LocationHash[$Location.id] = @{
            ipRanges  = $Location.ipRanges.cidrAddress
            isTrusted = $Location.isTrusted
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
                            $LocationHash[$_]['ipRanges']
                        }
                        else { $_ } }) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'excludeLocations'
            Expression = { @($_.Conditions.locations.excludeLocations).foreach{
                    if ($LocationHash.ContainsKey($_)) { $LocationHash[$_] } else { $_ } } -ne '' -join "`r`n" }
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
                        try { Get-GraphUser -UserId $_ }
                        catch { } }) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'excludeUsers'
            Expression = { @($_.Conditions.users.excludeUsers.foreach{
                        try { Get-GraphUser -UserId $_ }
                        catch { } }) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'includeGroups'
            Expression = { @($_.Conditions.users.includeGroups.foreach{
                        try { Get-GraphGroup -UserId $_ }
                        catch { } }) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'excludeGroups'
            Expression = { @($_.Conditions.users.excludeGroups.foreach{
                        try { Get-GraphGroup -UserId $_ }
                        catch { } }) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'includeRoles'
            Expression = { @($_.Conditions.applications.includeRoles.foreach{
                        if ($RoleHash.ContainsKey($_)) { $RoleHash[$_] } }) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'excludeRoles'
            Expression = { @($_.Conditions.applications.excludeRoles.foreach{
                        if ($RoleHash.ContainsKey($_)) { $RoleHash[$_] } }) -ne '' -join "`r`n" }
        }
    )

}