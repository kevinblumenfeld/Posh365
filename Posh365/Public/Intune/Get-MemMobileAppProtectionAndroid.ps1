function Get-MemMobileAppProtectionAndroid {
    param (

    )
    $Excludes = @(
        'allowedDataIngestionLocations', 'allowedDataStorageLocations', 'apps', 'assignments'
        'deploymentSummary', 'exemptedAppPackages', 'displayName', 'allowedAndroidDeviceModels'
        'approvedKeyboards', 'apps@odata.context', 'deploymentSummary@odata.context', 'assignments@odata.context'
        'allowedInboundDataTransferSources', 'allowedOutboundDataTransferDestinations'
        'allowedOutboundClipboardSharingLevel', 'allowedOutboundClipboardSharingExceptionLength'
        'managedBrowserToOpenLinksRequired', 'managedBrowser', 'createdDateTime'
        'lastModifiedDateTime', 'roleScopeTagIds', 'version', 'id'
        'pinRequired', 'maximumPinRetries', 'simplePinBlocked', 'minimumPinLength'
        'pinCharacterSet', 'periodBeforePinReset', 'disableAppPinIfDevicePinIsSet'
        'appActionIfMaximumPinRetriesExceeded', 'pinRequiredInsteadOfBiometricTimeout'
        'previousPinBlockCount', 'targetedAppManagementLevels', 'saveAsBlocked'
        'dataBackupBlocked', 'dialerRestrictionLevel', 'customDialerAppPackageId'
        'customDialerAppDisplayName', 'blockDataIngestionIntoOrganizationDocuments'
        'screenCaptureBlocked', 'keyboardsRestricted', 'encryptAppData'
        'disableAppEncryptionIfDeviceEncryptionIsEnabled', 'contactSyncBlocked'
        'printBlocked', 'customBrowserDisplayName', 'customBrowserPackageId'
    )
    Get-MemMobileAppProtectionAndroidData | Select-Object -ExcludeProperty $Excludes -Property @(
        @{
            Name       = 'DisplayName'
            Expression = { $_.DisplayName }
        }
        @{
            Name       = 'targetedAppManagementLevels'
            Expression = { $_.targetedAppManagementLevels }
        }
        @{
            Name       = 'apps'
            Expression = { @($_.apps.id) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'assignments'
            Expression = { @(($_.Assignments.Target.GroupID.foreach{
                            try { Get-GraphGroup -ErrorAction Stop -GroupId $_ }
                            catch { } }).displayName) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'dataBackupBlocked' # Backup org data to Android backup services
            Expression = { $_.dataBackupBlocked }
        }
        @{
            Name       = 'allowedOutboundDataTransferDestinations' # Send org data to other apps
            Expression = { $_.allowedOutboundDataTransferDestinations }
        }
        @{
            Name       = 'exemptedAppPackages'
            Expression = { if ($_.allowedOutboundDataTransferDestinations -eq 'managedApps') {
                    @($_.exemptedAppPackages.foreach{ '{0} --> {1}' -f $_.Name, $_.Value }) -ne '' -join "`r`n"
                }
            }
        }
        @{
            Name       = 'saveAsBlocked' # Save copies of org data
            Expression = { if ($_.allowedOutboundDataTransferDestinations -eq 'managedApps') {
                    $_.saveAsBlocked
                }
            }
        }
        @{
            Name       = 'allowedDataStorageLocations' # Allow user to save copies to selected services
            Expression = { if ($_.allowedOutboundDataTransferDestinations -eq 'managedApps' -and $_.saveAsBlocked -eq $true) {
                    @($_.allowedDataStorageLocations) -ne '' -join "`r`n"
                }
            }
        }
        @{
            Name       = 'dialerRestrictionLevel' # Transfer telecommunication data to
            Expression = { if ($_.allowedOutboundDataTransferDestinations -eq 'managedApps') {
                    $_.dialerRestrictionLevel
                }
            }
        }
        @{
            Name       = 'customDialerAppPackageId' # Dialer App Package ID
            Expression = { if ($_.allowedOutboundDataTransferDestinations -eq 'managedApps' -and $_.dialerRestrictionLevel -eq 'customApp') {
                    $_.customDialerAppPackageId
                }
            }
        }
        @{
            Name       = 'customDialerAppDisplayName' # Dialer App Name
            Expression = { if ($_.allowedOutboundDataTransferDestinations -eq 'managedApps' -and $_.dialerRestrictionLevel -eq 'customApp') {
                    $_.customDialerAppDisplayName
                }
            }
        }
        @{
            Name       = 'allowedInboundDataTransferSources' # Receive data from other apps
            Expression = { $_.allowedInboundDataTransferSources }
        }
        @{
            Name       = 'blockDataIngestionIntoOrganizationDocuments' # Open data into Org documents
            Expression = { if ($_.allowedInboundDataTransferSources -eq 'managedApps') {
                    $_.blockDataIngestionIntoOrganizationDocuments
                }
            }
        }
        @{
            Name       = 'allowedDataIngestionLocations' # Allow users to open data from selected services
            Expression = { if ($_.allowedInboundDataTransferSources -eq 'managedApps' -and $_.blockDataIngestionIntoOrganizationDocuments -eq $true) {
                    @($_.allowedDataIngestionLocations) -ne '' -join "`r`n"
                }
            }
        }
        @{
            Name       = 'allowedOutboundClipboardSharingLevel' # Restrict cut, copy, and paste between other apps
            Expression = { $_.allowedOutboundClipboardSharingLevel }
        }
        @{
            Name       = 'allowedOutboundClipboardSharingExceptionLength' # Cut and copy character limit for any app
            Expression = { if ($_.allowedOutboundClipboardSharingLevel -ne 'allApps') {
                    $_.allowedOutboundClipboardSharingExceptionLength
                }
            }
        }
        @{
            Name       = 'screenCaptureBlocked' # Screen capture and Google Assistant
            Expression = { $_.screenCaptureBlocked }
        }
        @{
            Name       = 'keyboardsRestricted' # Approved keyboards
            Expression = { $_.keyboardsRestricted }
        }
        @{
            Name       = 'approvedKeyboards' # Select keyboards to approve
            Expression = { if ($_.keyboardsRestricted) {
                    @($_.approvedKeyboards.foreach{ '{0} --> {1}' -f $_.Name, $_.Value }) -ne '' -join "`r`n"
                }
            }
        }
        @{
            Name       = 'encryptAppData' # Encrypt org data
            Expression = { $_.encryptAppData }
        }
        @{
            Name       = 'disableAppEncryptionIfDeviceEncryptionIsEnabled' # Encrypt org data on enrolled devices
            Expression = { if ($_.encryptAppData) {
                    $_.disableAppEncryptionIfDeviceEncryptionIsEnabled
                }
            }
        }
        @{
            Name       = 'contactSyncBlocked' # Sync policy managed app data with native apps
            Expression = { $_.contactSyncBlocked }
        }
        @{
            Name       = 'printBlocked' # Printing org data
            Expression = { $_.printBlocked }
        }
        @{
            Name       = 'managedBrowserToOpenLinksRequired' # (Coupled with below) Restrict web content transfer with other apps
            Expression = { $_.managedBrowserToOpenLinksRequired }
        }
        @{
            Name       = 'managedBrowser' # (Coupled with above) Restrict web content transfer with other apps
            Expression = { $_.managedBrowser }
        }
        @{
            Name       = 'customBrowserPackageId' # Unmanaged Browser ID
            Expression = { $_.customBrowserPackageId }
        }
        @{
            Name       = 'customBrowserDisplayName' # Unmanaged Browser Name
            Expression = { $_.customBrowserDisplayName }
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
            Expression = { $_.minimumPinLength }
        }
        @{
            Name       = 'pinCharacterSet'
            Expression = { $_.pinCharacterSet }
        }
        @{
            Name       = 'periodBeforePinReset'
            Expression = { $_.periodBeforePinReset }
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
            Expression = { $_.pinRequiredInsteadOfBiometricTimeout }
        }
        @{
            Name       = 'previousPinBlockCount'
            Expression = { $_.previousPinBlockCount }
        }
        '*'
        @{
            Name       = 'allowedAndroidDeviceModels'
            Expression = { @($_.allowedAndroidDeviceModels) -ne '' -join "`r`n" }
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