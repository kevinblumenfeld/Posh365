function Get-MemMobileAppConfigReport {
    param (

    )
    $Excludes = @(
        'assignments', 'settings', 'targetedMobileApps', 'DisplayName'
        'assignments@odata.context', 'payloadJson', 'encodedSettingXml'
        'profileApplicability', 'permissionActions', 'appSupportsOemConfig'
        'packageId'
    )
    Get-MemMobileAppConfig | Select-Object -ExcludeProperty $Excludes -Property @(
        @{
            Name       = 'DisplayName'
            Expression = { $_.DisplayName }
        }
        @{
            Name       = 'targetedMobileApps'
            Expression = { @(($_.targetedMobileApps.foreach{ Get-MemMobileApp -AppId $_ }).displayName) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'assignments'
            Expression = { @(($_.Assignments.Target.GroupID.foreach{ Get-GraphGroup -GroupId $_ }).displayName) -ne '' -join "`r`n" }
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
    )
}