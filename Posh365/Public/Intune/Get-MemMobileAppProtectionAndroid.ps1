function Get-MemMobileAppProtectionAndroid {
    param (

    )
    $Excludes = @(
        'allowedDataIngestionLocations', 'allowedDataStorageLocations', 'apps', 'assignments'
        'deploymentSummary', 'exemptedAppPackages', 'displayName', 'allowedAndroidDeviceModels'
        'approvedKeyboards', 'deploymentSummary@odata.context', 'apps@odata.context'
        'deploymentSummary@odata.context', 'assignments@odata.context'
    )
    Get-MemMobileAppProtectionAndroidData | Select-Object -ExcludeProperty $Excludes -Property @(
        @{
            Name       = 'DisplayName'
            Expression = { $_.DisplayName }
        }
        @{
            Name       = 'apps'
            Expression = { @($_.apps.id) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'assignments'
            Expression = { @(($_.Assignments.Target.GroupID.foreach{ Get-GraphGroup -GroupId $_ }).displayName) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'allowedDataIngestionLocations'
            Expression = { @($_.allowedDataIngestionLocations) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'allowedDataStorageLocations'
            Expression = { @($_.allowedDataStorageLocations) -ne '' -join "`r`n" }
        }
        '*'
        @{
            Name       = 'allowedAndroidDeviceModels'
            Expression = { @($_.allowedAndroidDeviceModels) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'approvedKeyboards'
            Expression = { @($_.approvedKeyboards) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'exemptedAppPackages'
            Expression = { @($_.exemptedAppPackages.foreach{ '{0} --> {1}' -f $_.Name, $_.Value }) -ne '' -join "`r`n" }
        }
    )
}