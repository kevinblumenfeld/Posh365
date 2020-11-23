function Get-MemMobileDeviceConfigiOSDeviceRestrictions {
    param (

    )
    $Excludes = @(
        'assignments', 'displayName', 'createdDateTime', 'lastModifiedDateTime'
        'version', 'assignments@odata.context', 'roleScopeTagIds', 'id', '@odata.type'
        'emailInDomainSuffixes', 'safariManagedDomains', 'safariPasswordAutoFillDomains'
        'appsSingleAppModeList', 'appsVisibilityList', 'compliantAppsList', 'networkUsageRules'
    )
    Get-MemMobileDeviceConfigiOSDeviceRestrictionsData | Select-Object -ExcludeProperty $Excludes -Property @(
        @{
            Name       = 'DisplayName'
            Expression = { $_.DisplayName }
        }
        @{
            Name       = 'assignments'
            Expression = { @(($_.Assignments.Target.GroupID.foreach{
                            try { Get-GraphGroup -ErrorAction Stop -GroupId $_ }
                            catch { } }).displayName) -ne '' -join "`r`n" }
        }
        '*'
        @{
            Name       = 'emailInDomainSuffixes'
            Expression = { @($_.emailInDomainSuffixes) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'safariManagedDomains'
            Expression = { @($_.safariManagedDomains) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'safariPasswordAutoFillDomains'
            Expression = { @($_.safariPasswordAutoFillDomains) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'appsSingleAppModeList'
            Expression = { @($_.appsSingleAppModeList) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'compliantAppsList'
            Expression = { @($_.compliantAppsList) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'networkUsageRules'
            Expression = { @($_.networkUsageRules) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'createdDateTime'
            Expression = { $_.createdDateTime }
        }
        @{
            Name       = 'lastModifiedDateTime'
            Expression = { $_.lastModifiedDateTime }
        }
        @{
            Name       = 'roleScopeTagIds'
            Expression = { $_.roleScopeTagIds }
        }
        @{
            Name       = 'id'
            Expression = { $_.id }
        }
        @{
            Name       = '@odata.type'
            Expression = { $_.'@odata.type' }
        }
        @{
            Name       = 'version'
            Expression = { $_.version }
        }
    )
}