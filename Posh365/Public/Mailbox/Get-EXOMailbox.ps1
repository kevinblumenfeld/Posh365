function Get-EXOMailbox {
    <#
    .SYNOPSIS
    Export Office 365 Mailboxes

    .DESCRIPTION
    Export Office 365 Mailboxes

    .PARAMETER SpecificMailboxes
    Provide specific mailboxes to report on.  Otherwise, all mailboxes will be reported.  Please review the examples provided.

    .PARAMETER DetailedReport
    Provides a full report of all attributes.  Otherwise, only a refined report will be given.

    .EXAMPLE
    Get-EXOMailbox | Export-Csv c:\scripts\All365Mailboxes.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    Get-EXOMailbox -ArchivesOnly | Export-Csv c:\scripts\All365Mailboxes.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    '{emailaddresses -like "*contoso.com"}' | Get-EXOMailbox | Export-Csv c:\scripts\365Mailboxes.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    '{emailaddresses -like "*contoso.com"}' | Get-EXOMailbox -ArchivesOnly | Export-Csv c:\scripts\365Mailboxes.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    '{emailaddresses -like "*contoso.com"}' | Get-EXOMailbox -DetailedReport | Export-Csv c:\scripts\365Mailboxes_Detailed.csv -notypeinformation -encoding UTF8

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch] $DetailedReport,

        [Parameter(Mandatory = $false)]
        [switch] $ArchivesOnly,

        [Parameter(ValueFromPipeline = $true, Mandatory = $false)]
        [string[]] $MailboxFilter
    )
    Begin {
        if ($DetailedReport) {
            $Selectproperties = @(
                'Name', 'RecipientTypeDetails', 'DisplayName', 'UserPrincipalName', 'Identity', 'PrimarySmtpAddress'
                'AddressBookPolicy', 'ArbitrationMailbox', 'ArchiveDatabase', 'ArchiveDomain', 'DataEncryptionPolicy', 'DefaultPublicFolderMailbox'
                'DisabledArchiveDatabase', 'EffectivePublicFolderMailbox', 'EndDateForRetentionHold', 'ForwardingAddress', 'ForwardingSmtpAddress', 'InactiveMailboxRetireTime'
                'LastExchangeChangedTime', 'LitigationHoldDate', 'MailboxContainerGuid', 'MailboxMoveSourceMDB', 'MailboxMoveTargetMDB', 'MailboxProvisioningConstraint'
                'MailboxRegion', 'MailboxRegionLastUpdateTime', 'MailTip', 'ManagedFolderMailboxPolicy', 'MaxBlockedSenders', 'MaxSafeSenders', 'OfflineAddressBook'
                'OrphanSoftDeleteTrackingTime', 'QueryBaseDN', 'ReconciliationId', 'RemoteAccountPolicy', 'ResourceCapacity', 'ResourceType', 'RoomMailboxAccountEnabled'
                'SCLDeleteEnabled', 'SCLDeleteThreshold', 'SCLJunkEnabled', 'SCLJunkThreshold', 'SCLQuarantineEnabled', 'SCLQuarantineThreshold', 'SCLRejectEnabled'
                'SCLRejectThreshold', 'SiloName', 'StartDateForRetentionHold', 'ThrottlingPolicy', 'UnifiedMailbox', 'WhenSoftDeleted', 'AccountDisabled', 'AntispamBypassEnabled'
                'AuditEnabled', 'AutoExpandingArchiveEnabled', 'CalendarRepairDisabled', 'CalendarVersionStoreDisabled', 'ComplianceTagHoldApplied', 'DelayHoldApplied'
                'DeliverToMailboxAndForward', 'DisabledMailboxLocations', 'DowngradeHighPriorityMessagesEnabled', 'ElcProcessingDisabled', 'EmailAddressPolicyEnabled'
                'HasPicture', 'HasSnackyAppData', 'HasSpokenName', 'HiddenFromAddressListsEnabled', 'ImListMigrationCompleted', 'IncludeInGarbageCollection', 'IsDirSynced'
                'IsExcludedFromServingHierarchy', 'IsHierarchyReady', 'IsHierarchySyncEnabled', 'IsInactiveMailbox', 'IsLinked', 'IsMachineToPersonTextMessagingEnabled'
                'IsMailboxEnabled', 'IsMonitoringMailbox', 'IsPersonToPersonTextMessagingEnabled', 'IsResource', 'IsRootPublicFolderMailbox', 'IsShared', 'IsSoftDeletedByDisable'
                'IsSoftDeletedByRemove', 'IsValid', 'LitigationHoldEnabled', 'MessageCopyForSendOnBehalfEnabled', 'MessageCopyForSentAsEnabled', 'MessageTrackingReadStatusEnabled'
                'ModerationEnabled', 'QueryBaseDNRestrictionEnabled', 'RequireSenderAuthenticationEnabled', 'ResetPasswordOnNextLogon', 'RetainDeletedItemsUntilBackup'
                'RetentionHoldEnabled', 'SingleItemRecoveryEnabled', 'SKUAssigned', 'UMEnabled', 'UseDatabaseQuotaDefaults', 'UseDatabaseRetentionDefaults', 'WasInactiveMailbox'
                'StsRefreshTokensValidFrom', 'WhenChanged', 'WhenChangedUTC', 'WhenCreated', 'WhenCreatedUTC', 'WhenMailboxCreated', 'ArchiveGuid', 'DisabledArchiveGuid', 'ExchangeGuid'
                'Guid', 'AdminDisplayVersion', 'Alias', 'ArchiveQuota', 'ArchiveRelease', 'ArchiveState', 'ArchiveStatus', 'ArchiveWarningQuota', 'AuditLogAgeLimit', 'CalendarLoggingQuota'
                'CustomAttribute1', 'CustomAttribute10', 'CustomAttribute11', 'CustomAttribute12', 'CustomAttribute13', 'CustomAttribute14', 'CustomAttribute15', 'CustomAttribute2'
                'CustomAttribute3', 'CustomAttribute4', 'CustomAttribute5', 'CustomAttribute6', 'CustomAttribute7', 'CustomAttribute8', 'CustomAttribute9', 'Database'
                'DistinguishedName', 'ExchangeSecurityDescriptor', 'ExchangeUserAccountControl', 'ExchangeVersion', 'ExternalDirectoryObjectId', 'ExternalOofOptions', 'Id'
                'ImmutableId', 'IssueWarningQuota', 'JournalArchiveAddress', 'LegacyExchangeDN', 'LinkedMasterAccount', 'LitigationHoldDuration', 'LitigationHoldOwner'
                'MailboxMoveBatchName', 'MailboxMoveFlags', 'MailboxMoveRemoteHostName', 'MailboxMoveStatus', 'MailboxPlan', 'MailboxRelease', 'MaxReceiveSize', 'MaxSendSize'
                'MicrosoftOnlineServicesID', 'NetID', 'ObjectCategory', 'ObjectState', 'Office', 'OrganizationalUnit', 'OrganizationId', 'OriginatingServer'
                'ProhibitSendQuota', 'ProhibitSendReceiveQuota', 'RecipientLimits', 'RecipientType', 'RecoverableItemsQuota', 'RecoverableItemsWarningQuota'
                'RemoteRecipientType', 'RetainDeletedItemsFor', 'RetentionComment', 'RetentionPolicy', 'RetentionUrl', 'RoleAssignmentPolicy', 'RulesQuota', 'SamAccountName'
                'SendModerationNotifications', 'ServerLegacyDN', 'ServerName', 'SharingPolicy', 'SimpleDisplayName', 'SourceAnchor', 'UsageLocation'
                'WindowsEmailAddress', 'WindowsLiveID'
            )

            $CalculatedProps = @(
                @{n = "AcceptMessagesOnlyFrom" ; e = { [string]::join("|", [String[]]$_.AcceptMessagesOnlyFrom -ne '') } },
                @{n = "AcceptMessagesOnlyFromDLMembers" ; e = { [string]::join("|", [String[]]$_.AcceptMessagesOnlyFromDLMembers -ne '') } },
                @{n = "AcceptMessagesOnlyFromSendersOrMembers" ; e = { [string]::join("|", [String[]]$_.AcceptMessagesOnlyFromSendersOrMembers -ne '') } },
                @{n = "AddressListMembership" ; e = { [string]::join("|", [String[]]$_.AddressListMembership -ne '') } },
                @{n = "AdministrativeUnits" ; e = { [string]::join("|", [String[]]$_.AdministrativeUnits -ne '') } },
                @{n = "BypassModerationFromSendersOrMembers" ; e = { [string]::join("|", [String[]]$_.BypassModerationFromSendersOrMembers -ne '') } },
                @{n = "GeneratedOfflineAddressBooks" ; e = { [string]::join("|", [String[]]$_.GeneratedOfflineAddressBooks -ne '') } },
                @{n = "GrantSendOnBehalfTo" ; e = { [string]::join("|", [String[]]$_.GrantSendOnBehalfTo -ne '') } },
                @{n = "ModeratedBy" ; e = { [string]::join("|", [String[]]$_.ModeratedBy -ne '') } },
                @{n = "RejectMessagesFrom" ; e = { [string]::join("|", [String[]]$_.RejectMessagesFrom -ne '') } },
                @{n = "RejectMessagesFromDLMembers" ; e = { [string]::join("|", [String[]]$_.RejectMessagesFromDLMembers -ne '') } },
                @{n = "RejectMessagesFromSendersOrMembers" ; e = { [string]::join("|", [String[]]$_.RejectMessagesFromSendersOrMembers -ne '') } },
                @{n = "PersistedCapabilities" ; e = { [string]::join("|", [String[]]$_.PersistedCapabilities -ne '') } },
                @{n = "AuditAdmin" ; e = { [string]::join("|", [String[]]$_.AuditAdmin -ne '') } },
                @{n = "AuditDelegate" ; e = { [string]::join("|", [String[]]$_.AuditDelegate -ne '') } },
                @{n = "AuditOwner" ; e = { [string]::join("|", [String[]]$_.AuditOwner -ne '') } },
                @{n = "MailboxProvisioningPreferences" ; e = { [string]::join("|", [String[]]$_.MailboxProvisioningPreferences -ne '') } },
                @{n = "UserCertificate" ; e = { [string]::join("|", [String[]]$_.UserCertificate -ne '') } },
                @{n = "UserSMimeCertificate" ; e = { [string]::join("|", [String[]]$_.UserSMimeCertificate -ne '') } },
                @{n = "Languages" ; e = { [string]::join("|", [String[]]$_.Languages -ne '') } },
                @{n = "AggregatedMailboxGuids" ; e = { [string]::join("|", [String[]]$_.AggregatedMailboxGuids -ne '') } },
                @{n = "ArchiveName" ; e = { [string]::join("|", [String[]]$_.ArchiveName -ne '') } },
                @{n = "ExtensionCustomAttribute1" ; e = { [string]::join("|", [String[]]$_.ExtensionCustomAttribute1 -ne '') } },
                @{n = "ExtensionCustomAttribute2" ; e = { [string]::join("|", [String[]]$_.ExtensionCustomAttribute2 -ne '') } },
                @{n = "ExtensionCustomAttribute3" ; e = { [string]::join("|", [String[]]$_.ExtensionCustomAttribute3 -ne '') } },
                @{n = "ExtensionCustomAttribute4" ; e = { [string]::join("|", [String[]]$_.ExtensionCustomAttribute4 -ne '') } },
                @{n = "ExtensionCustomAttribute5" ; e = { [string]::join("|", [String[]]$_.ExtensionCustomAttribute5 -ne '') } },
                @{n = "Extensions" ; e = { [string]::join("|", [String[]]$_.Extensions -ne '') } },
                @{n = "InPlaceHolds" ; e = { [string]::join("|", [String[]]$_.InPlaceHolds -ne '') } },
                @{n = "MailTipTranslations" ; e = { [string]::join("|", [String[]]$_.MailTipTranslations -ne '') } },
                @{n = "ObjectClass" ; e = { [string]::join("|", [String[]]$_.ObjectClass -ne '') } },
                @{n = "PoliciesExcluded" ; e = { [string]::join("|", [String[]]$_.PoliciesExcluded -ne '') } },
                @{n = "PoliciesIncluded" ; e = { [string]::join("|", [String[]]$_.PoliciesIncluded -ne '') } },
                @{n = "ProtocolSettings" ; e = { [string]::join("|", [String[]]$_.ProtocolSettings -ne '') } },
                @{n = "ResourceCustom" ; e = { [string]::join("|", [String[]]$_.ResourceCustom -ne '') } },
                @{n = "UMDtmfMap" ; e = { [string]::join("|", [String[]]$_.UMDtmfMap -ne '') } },
                @{n = "EmailAddresses" ; e = { [string]::join("|", [String[]]$_.EmailAddresses -ne '') } },
                @{n = "x500" ; e = { "x500:" + $_.LegacyExchangeDN } },
                @{n = "MailboxLocations" ; e = { [string]::join("|", [String[]]$_.MailboxLocations -ne '') } }
            )
        }
        else {
            $Selectproperties = @(
                'Name', 'RecipientTypeDetails', 'DisplayName', 'UserPrincipalName', 'Identity', 'PrimarySmtpAddress', 'Alias'
                'ForwardingAddress', 'ForwardingSmtpAddress', 'LitigationHoldDate', 'AccountDisabled', 'DeliverToMailboxAndForward'
                'HiddenFromAddressListsEnabled', 'IsDirSynced', 'LitigationHoldEnabled', 'LitigationHoldDuration'
                'LitigationHoldOwner', 'Office', 'RetentionPolicy', 'WindowsEmailAddress'
            )

            $CalculatedProps = @(
                @{n = "ArchiveName" ; e = { ($_.ArchiveName | Where-Object { $_ -ne $null }) -join ";" } },
                @{n = "AcceptMessagesOnlyFrom" ; e = { ($_.AcceptMessagesOnlyFrom | Where-Object { $_ -ne $null }) -join ";" } },
                @{n = "AcceptMessagesOnlyFromDLMembers" ; e = { ($_.AcceptMessagesOnlyFromDLMembers | Where-Object { $_ -ne $null }) -join ";" } },
                @{n = "AcceptMessagesOnlyFromSendersOrMembers" ; e = { ($_.AcceptMessagesOnlyFromSendersOrMembers | Where-Object { $_ -ne $null }) -join ";" } },
                @{n = "RejectMessagesFrom" ; e = { ($_.RejectMessagesFrom | Where-Object { $_ -ne $null }) -join ";" } },
                @{n = "RejectMessagesFromDLMembers" ; e = { ($_.RejectMessagesFromDLMembers | Where-Object { $_ -ne $null }) -join ";" } },
                @{n = "RejectMessagesFromSendersOrMembers" ; e = { ($_.RejectMessagesFromSendersOrMembers | Where-Object { $_ -ne $null }) -join ";" } },
                @{n = "InPlaceHolds" ; e = { ($_.InPlaceHolds | Where-Object { $_ -ne $null }) -join ";" } },
                @{n = "x500" ; e = { "x500:" + $_.LegacyExchangeDN } },
                @{n = "EmailAddresses" ; e = { ($_.EmailAddresses | Where-Object { $_ -ne $null }) -join '|' } }
            )
        }
    }
    Process {
        if ($MailboxFilter) {
            foreach ($CurMailboxFilter in $MailboxFilter) {
                if (! $ArchivesOnly) {
                    Get-Mailbox -Filter $CurMailboxFilter -ResultSize unlimited | Select-Object ($Selectproperties + $CalculatedProps)
                }
                else {
                    Get-Mailbox -Archive -Filter $CurMailboxFilter -ResultSize unlimited | Select-Object ($Selectproperties + $CalculatedProps)
                }
            }
        }
        else {
            if (! $ArchivesOnly) {
                Get-Mailbox -ResultSize unlimited | Select-Object ($Selectproperties + $CalculatedProps)
            }
            else {
                Get-Mailbox -Archive -ResultSize unlimited | Select-Object ($Selectproperties + $CalculatedProps)
            }
        }
    }
    End {

    }
}