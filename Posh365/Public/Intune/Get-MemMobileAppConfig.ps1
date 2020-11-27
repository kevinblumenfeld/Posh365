function Get-MemMobileAppConfig {
    param (

    )
    $Excludes = @(
        'assignments', 'settings', 'targetedMobileApps', 'DisplayName'
        'assignments@odata.context', 'payloadJson', 'encodedSettingXml'
        'profileApplicability', 'permissionActions', 'appSupportsOemConfig'
        'packageId', 'version', '@odata.type', 'id', 'roleScopeTagIds'
        'lastModifiedDateTime', 'createdDateTime'
    )
    Get-MemMobileAppConfigData | Select-Object -ExcludeProperty $Excludes -Property @(
        @{
            Name       = 'DisplayName'
            Expression = { $_.DisplayName }
        }
        @{
            Name       = 'targetedMobileApps'
            Expression = { @(($_.targetedMobileApps.foreach{
                            try { Get-MemMobileAppData -AppId $_ }
                            catch { } }).displayName) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'assignments'
            Expression = { @(($_.Assignments.Target.GroupID.foreach{
                            try { Get-GraphGroup -ErrorAction Stop -GroupId $_ }
                            catch { } }).displayName) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'Settings'
            Expression = { @($_.Settings.foreach{ '{0} --> {1}' -f $_.AppConfigKey, $_.AppConfigKeyValue }) -ne '' -join "`r`n" }
        }
        '*'
        @{
            Name       = 'profileApplicability'
            Expression = { $_.profileApplicability }
        }
        @{
            Name       = 'permissionActions'
            Expression = { @($_.permissionActions) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'appSupportsOemConfig'
            Expression = { $_.appSupportsOemConfig }
        }
        @{
            Name       = 'packageId'
            Expression = { $_.packageId }
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