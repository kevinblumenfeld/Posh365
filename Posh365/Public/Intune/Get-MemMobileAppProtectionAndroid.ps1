function Get-MemMobileAppProtectionAndroid {
    param (

    )
    $Excludes = @(
        'allowedDataIngestionLocations', 'allowedDataStorageLocations', 'apps', 'assignments'
        'deploymentSummary', 'exemptedAppPackages', 'displayName', 'allowedAndroidDeviceModels'
        'approvedKeyboards', 'deploymentSummary@odata.context', 'apps@odata.context'
        'deploymentSummary@odata.context', 'assignments@odata.context'
        'allowedInboundDataTransferSources', 'allowedOutboundDataTransferDestinations'
        'allowedOutboundClipboardSharingLevel', 'allowedOutboundClipboardSharingExceptionLength'
        'managedBrowserToOpenLinksRequired', 'managedBrowser', 'createdDateTime'
        'lastModifiedDateTime', 'roleScopeTagIds', 'version', 'id'
        'pinRequired', 'maximumPinRetries', 'simplePinBlocked', 'minimumPinLength'
        'pinCharacterSet', 'periodBeforePinReset', 'disableAppPinIfDevicePinIsSet'
        'appActionIfMaximumPinRetriesExceeded', 'pinRequiredInsteadOfBiometricTimeout'
        'previousPinBlockCount'
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
        @{
            Name       = 'allowedInboundDataTransferSources'
            Expression = { $_.allowedInboundDataTransferSources }
        }
        @{
            Name       = 'allowedOutboundDataTransferDestinations'
            Expression = { $_.allowedOutboundDataTransferDestinations }
        }
        @{
            Name       = 'allowedOutboundClipboardSharingLevel'
            Expression = { $_.allowedOutboundClipboardSharingLevel }
        }
        @{
            Name       = 'allowedOutboundClipboardSharingExceptionLength'
            Expression = { $_.allowedOutboundClipboardSharingExceptionLength }
        }
        @{
            Name       = 'managedBrowserToOpenLinksRequired'
            Expression = { $_.managedBrowserToOpenLinksRequired }
        }
        @{
            Name       = 'pinRequired'
            Expression = { $_.pinRequired }
        }
        @{
            Name       = 'maximumPinRetries'
            Expression = { $_.maximumPinRetries }
        }
        @{
            Name       = 'simplePinBlocked'
            Expression = { $_.simplePinBlocked }
        }
        @{
            Name       = 'minimumPinLength'
            Expression = { $_.allowedOutboundClipboardSharingLevel }
        }
        @{
            Name       = 'pinCharacterSet'
            Expression = { $_.allowedOutboundClipboardSharingExceptionLength }
        }
        @{
            Name       = 'periodBeforePinReset'
            Expression = { $_.managedBrowserToOpenLinksRequired }
        }
        @{
            Name       = 'disableAppPinIfDevicePinIsSet'
            Expression = { $_.disableAppPinIfDevicePinIsSet }
        }
        @{
            Name       = 'appActionIfMaximumPinRetriesExceeded'
            Expression = { $_.appActionIfMaximumPinRetriesExceeded }
        }
        @{
            Name       = 'pinRequiredInsteadOfBiometricTimeout'
            Expression = { $_.disableAppPinIfDevicePinIsSet }
        }
        @{
            Name       = 'previousPinBlockCount'
            Expression = { $_.managedBrowser }
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
            Name       = 'version'
            Expression = { $_.version }
        }
    )
}