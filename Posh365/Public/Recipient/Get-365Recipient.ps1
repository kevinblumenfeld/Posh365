function Get-365Recipient {
    <#
    .SYNOPSIS
    Export Office 365 Recipients

    .DESCRIPTION
    Export Office 365 Recipients

    .PARAMETER SpecificRecipients
    Provide specific Recipients to report on.  Otherwise, all Recipients will be reported.  Please review the examples provided.

    .PARAMETER DetailedReport
    Provides a full report of all attributes.  Otherwise, only a refined report will be given.

    .EXAMPLE
    Get-365Recipient | Export-Csv c:\scripts\All365Recipients.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    '{UserPrincipalName -like "*contoso.com" -or
        emailaddresses -like "*contoso.com" -or
        ExternalEmailAddress -like "*contoso.com" -or
        PrimarySmtpAddress -like "*contoso.com"}' | Get-365Recipient | Export-Csv .\RecipientReport.csv -notypeinformation -encoding UTF8
    .EXAMPLE


    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch] $DetailedReport,

        [Parameter(ValueFromPipeline = $true, Mandatory = $false)]
        [string[]] $RecipientFilter
    )
    Begin {
        if ($DetailedReport) {
            $Selectproperties = @(
                'DisplayName', 'Identity', 'RecipientType', 'RecipientTypeDetails', 'PrimarySmtpAddress', 'WindowsLiveID', 'Name', 'Alias', 'AddressBookPolicy'
                'ArbitrationMailbox', 'ArchiveDatabase', 'ArchiveDomain', 'DataEncryptionPolicy', 'DefaultPublicFolderMailbox', 'DisabledArchiveDatabase'
                'EffectivePublicFolderMailbox', 'EndDateForRetentionHold', 'ForwardingAddress', 'ForwardingSmtpAddress', 'InactiveMailboxRetireTime'
                'LastExchangeChangedTime', 'LitigationHoldDate', 'MailboxContainerGuid', 'MailboxMoveSourceMDB', 'MailboxMoveTargetMDB'
                'MailboxProvisioningConstraint', 'MailboxRegion', 'MailboxRegionLastUpdateTime', 'MailTip', 'ManagedFolderMailboxPolicy', 'MaxBlockedSenders'
                'MaxSafeSenders', 'OfflineAddressBook', 'OrphanSoftDeleteTrackingTime', 'QueryBaseDN', 'ReconciliationId', 'RemoteAccountPolicy'
                'ResourceCapacity', 'ResourceType', 'RoomMailboxAccountEnabled', 'SCLDeleteEnabled', 'SCLDeleteThreshold', 'SCLJunkEnabled'
                'SCLJunkThreshold', 'SCLQuarantineEnabled', 'SCLQuarantineThreshold', 'SCLRejectEnabled', 'SCLRejectThreshold', 'SiloName'
                'StartDateForRetentionHold', 'ThrottlingPolicy', 'UnifiedMailbox', 'WhenSoftDeleted', 'AccountDisabled'
                'AntispamBypassEnabled', 'AuditEnabled', 'AutoExpandingArchiveEnabled', 'CalendarRepairDisabled', 'CalendarVersionStoreDisabled'
                'ComplianceTagHoldApplied', 'DelayHoldApplied', 'DeliverToMailboxAndForward', 'DisabledMailboxLocations'
                'DowngradeHighPriorityMessagesEnabled', 'ElcProcessingDisabled', 'EmailAddressPolicyEnabled', 'HasPicture', 'HasSnackyAppData'
                'HasSpokenName', 'HiddenFromAddressListsEnabled', 'ImListMigrationCompleted', 'IncludeInGarbageCollection', 'IsDirSynced'
                'IsExcludedFromServingHierarchy', 'IsHierarchyReady', 'IsHierarchySyncEnabled', 'IsInactiveMailbox', 'IsLinked'
                'IsMachineToPersonTextMessagingEnabled', 'IsMailboxEnabled', 'IsMonitoringMailbox', 'IsPersonToPersonTextMessagingEnabled'
                'IsResource', 'IsRootPublicFolderMailbox', 'IsShared', 'IsSoftDeletedByDisable', 'IsSoftDeletedByRemove', 'IsValid', 'LitigationHoldEnabled'
                'MessageCopyForSendOnBehalfEnabled', 'MessageCopyForSentAsEnabled', 'MessageTrackingReadStatusEnabled', 'ModerationEnabled'
                'QueryBaseDNRestrictionEnabled', 'RequireSenderAuthenticationEnabled', 'ResetPasswordOnNextLogon', 'RetainDeletedItemsUntilBackup'
                'RetentionHoldEnabled', 'SingleItemRecoveryEnabled', 'SKUAssigned', 'UMEnabled', 'UseDatabaseQuotaDefaults', 'UseDatabaseRetentionDefaults'
                'WasInactiveMailbox', 'StsRefreshTokensValidFrom', 'WhenChanged', 'WhenChangedUTC', 'WhenCreated', 'WhenCreatedUTC', 'WhenMailboxCreated'
                'ArchiveGuid', 'DisabledArchiveGuid', 'ExchangeGuid', 'Guid', 'AdminDisplayVersion', 'ArchiveQuota', 'ArchiveRelease', 'ArchiveState'
                'ArchiveStatus', 'ArchiveWarningQuota', 'AuditLogAgeLimit', 'CalendarLoggingQuota', 'CustomAttribute1', 'CustomAttribute10', 'CustomAttribute11'
                'CustomAttribute12', 'CustomAttribute13', 'CustomAttribute14', 'CustomAttribute15', 'CustomAttribute2', 'CustomAttribute3', 'CustomAttribute4'
                'CustomAttribute5', 'CustomAttribute6', 'CustomAttribute7', 'CustomAttribute8', 'CustomAttribute9', 'Database', 'DistinguishedName'
                'ExchangeSecurityDescriptor', 'ExchangeUserAccountControl', 'ExchangeVersion', 'ExternalDirectoryObjectId', 'ExternalOofOptions', 'Id'
                'ImmutableId', 'IssueWarningQuota', 'JournalArchiveAddress', 'LegacyExchangeDN', 'LinkedMasterAccount', 'LitigationHoldDuration'
                'LitigationHoldOwner', 'MailboxMoveBatchName', 'MailboxMoveFlags', 'MailboxMoveRemoteHostName', 'MailboxMoveStatus', 'MailboxPlan'
                'MailboxRelease', 'MaxReceiveSize', 'MaxSendSize', 'MicrosoftOnlineServicesID', 'NetID', 'ObjectCategory', 'ObjectState', 'Office'
                'OrganizationalUnit', 'OrganizationId', 'OriginatingServer', 'ProhibitSendQuota', 'ProhibitSendReceiveQuota', 'RecipientLimits'
                'RecoverableItemsQuota', 'RecoverableItemsWarningQuota', 'RemoteRecipientType', 'RetainDeletedItemsFor'
                'RetentionComment', 'RetentionPolicy', 'RetentionUrl', 'RoleAssignmentPolicy', 'RulesQuota', 'SamAccountName', 'SendModerationNotifications'
                'ServerLegacyDN', 'ServerName', 'SharingPolicy', 'SimpleDisplayName', 'SourceAnchor', 'UsageLocation', 'UserPrincipalName', 'WindowsEmailAddress'
            )

            $CalculatedProps = @(
                @{n = "AcceptMessagesOnlyFrom" ; e = { @($_.AcceptMessagesOnlyFrom) -ne '' -join '|' } },
                @{n = "AcceptMessagesOnlyFromDLMembers" ; e = { @($_.AcceptMessagesOnlyFromDLMembers) -ne '' -join '|' } },
                @{n = "AcceptMessagesOnlyFromSendersOrMembers" ; e = { @($_.AcceptMessagesOnlyFromSendersOrMembers) -ne '' -join '|' } },
                @{n = "AddressListMembership" ; e = { @($_.AddressListMembership) -ne '' -join '|' } },
                @{n = "AdministrativeUnits" ; e = { @($_.AdministrativeUnits) -ne '' -join '|' } },
                @{n = "BypassModerationFromSendersOrMembers" ; e = { @($_.BypassModerationFromSendersOrMembers) -ne '' -join '|' } },
                @{n = "GrantSendOnBehalfTo" ; e = { @($_.GrantSendOnBehalfTo) -ne '' -join '|' } },
                @{n = "ModeratedBy" ; e = { @($_.ModeratedBy) -ne '' -join '|' } },
                @{n = "RejectMessagesFrom" ; e = { @($_.RejectMessagesFrom) -ne '' -join '|' } },
                @{n = "RejectMessagesFromDLMembers" ; e = { @($_.RejectMessagesFromSendersOrMembers) -ne '' -join '|' } },
                @{n = "RejectMessagesFromSendersOrMembers" ; e = { @($_.RejectMessagesFromSendersOrMembers) -ne '' -join '|' } },
                @{n = "PersistedCapabilities" ; e = { @($_.PersistedCapabilities) -ne '' -join '|' } },
                @{n = "AuditAdmin" ; e = { @($_.AuditAdmin) -ne '' -join '|' } },
                @{n = "AuditDelegate" ; e = { @($_.AuditDelegate) -ne '' -join '|' } },
                @{n = "AuditOwner" ; e = { @($_.AuditOwner) -ne '' -join '|' } },
                @{n = "MailboxProvisioningPreferences" ; e = { @($_.MailboxProvisioningPreferences) -ne '' -join '|' } },
                @{n = "UserCertificate" ; e = { @($_.UserCertificate) -ne '' -join '|' } },
                @{n = "UserSMimeCertificate" ; e = { @($_.UserSMimeCertificate) -ne '' -join '|' } },
                @{n = "Languages" ; e = { @($_.Languages) -ne '' -join '|' } },
                @{n = "AggregatedMailboxGuids" ; e = { @($_.AggregatedMailboxGuids) -ne '' -join '|' } },
                @{n = "ArchiveName" ; e = { @($_.ArchiveName) -ne '' -join '|' } },
                @{n = "ExtensionCustomAttribute1" ; e = { @($_.ExtensionCustomAttribute1) -ne '' -join '|' } },
                @{n = "ExtensionCustomAttribute2" ; e = { @($_.ExtensionCustomAttribute2) -ne '' -join '|' } },
                @{n = "ExtensionCustomAttribute3" ; e = { @($_.ExtensionCustomAttribute3) -ne '' -join '|' } },
                @{n = "ExtensionCustomAttribute4" ; e = { @($_.ExtensionCustomAttribute4) -ne '' -join '|' } },
                @{n = "ExtensionCustomAttribute5" ; e = { @($_.ExtensionCustomAttribute5) -ne '' -join '|' } },
                @{n = "Extensions" ; e = { @($_.Extensions) -ne '' -join '|' } },
                @{n = "InPlaceHolds" ; e = { @($_.InPlaceHolds) -ne '' -join '|' } },
                @{n = "MailTipTranslations" ; e = { @($_.MailTipTranslations) -ne '' -join '|' } },
                @{n = "ObjectClass" ; e = { @($_.ObjectClass) -ne '' -join '|' } },
                @{n = "PoliciesExcluded" ; e = { @($_.PoliciesExcluded) -ne '' -join '|' } },
                @{n = "PoliciesIncluded" ; e = { @($_.PoliciesIncluded) -ne '' -join '|' } },
                @{n = "ProtocolSettings" ; e = { @($_.ProtocolSettings) -ne '' -join '|' } },
                @{n = "ResourceCustom" ; e = { @($_.ResourceCustom) -ne '' -join '|' } },
                @{n = "UMDtmfMap" ; e = { @($_.UMDtmfMap) -ne '' -join '|' } },
                @{n = "EmailAddresses" ; e = { @($_.EmailAddresses) -ne '' -join '|' } },
                @{n = "x500" ; e = { "x500:" + $_.LegacyExchangeDN } },
                @{n = "MailboxLocations" ; e = { @($_.MailboxLocations) -ne '' -join '|' } },
                @{n = "ExchangeObjectId" ; e = { ($_.ExchangeObjectId).Guid } }
            )
        }
        else {
            $Selectproperties = @(
                'RecipientTypeDetails', 'Name', 'DisplayName', 'Office', 'Alias', 'Identity', 'PrimarySmtpAddress', 'UserPrincipalName'
                'WindowsEmailAddress', 'WindowsLiveID', 'ForwardingAddress', 'ForwardingSmtpAddress', 'LitigationHoldEnabled', 'LitigationHoldDuration'
                'LitigationHoldDate', 'DeliverToMailboxAndForward', 'IsDirSynced', 'RequireSenderAuthenticationEnabled', 'RetentionHoldEnabled'
                'SingleItemRecoveryEnabled'
            )

            $CalculatedProps = @(
                @{n = "EmailAddresses" ; e = { @($_.EmailAddresses) -ne '' -join '|' } },
                @{n = "AcceptMessagesOnlyFromSendersOrMembers" ; e = { @($_.AcceptMessagesOnlyFromSendersOrMembers) -ne '' -join '|' } },
                @{n = "RejectMessagesFromSendersOrMembers" ; e = { @($_.RejectMessagesFromSendersOrMembers) -ne '' -join '|' } },
                @{n = "ArchiveName" ; e = { @($_.ArchiveName) -ne '' -join '|' } }
                @{n = "InPlaceHolds" ; e = { @($_.InPlaceHolds) -ne '' -join '|' } }
            )
        }
    }
    Process {
        if ($RecipientFilter) {
            foreach ($CurRecipientFilter in $RecipientFilter) {
                Get-Recipient -Filter $CurRecipientFilter | Select-Object ($Selectproperties + $CalculatedProps)
            }
        }
        else {
            Get-Recipient -ResultSize unlimited | Select-Object ($Selectproperties + $CalculatedProps)
        }
    }
    End {

    }
}
