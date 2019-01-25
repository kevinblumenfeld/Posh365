function Get-ExchangeMailbox {
    <#
    .SYNOPSIS
    Export Exchange Mailboxes

    .DESCRIPTION
    Export Exchange Mailboxes

    .PARAMETER SpecificMailboxes
    Provide specific mailboxes to report on.  Otherwise, all mailboxes will be reported.  Please review the examples provided.

    .PARAMETER DetailedReport
    Provides a full report of all attributes.  Otherwise, only a refined report will be given.

    .EXAMPLE
    Get-ExchangeMailbox | Export-Csv c:\scripts\AllExchangeMailboxes.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    Get-ExchangeMailbox -ArchivesOnly | Export-Csv c:\scripts\AllExchangeMailboxes.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    '{emailaddresses -like "*contoso.com"}' | Get-ExchangeMailbox | Export-Csv c:\scripts\ExchangeMailboxes.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    '{emailaddresses -like "*contoso.com"}' | Get-ExchangeMailbox -ArchivesOnly | Export-Csv c:\scripts\ExchangeMailboxes.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    '{emailaddresses -like "*contoso.com"}' | Get-ExchangeMailbox -DetailedReport | Export-Csv c:\scripts\ExchangeMailboxes_Detailed.csv -notypeinformation -encoding UTF8

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
                @{n = "OU" ; e = {$_.DistinguishedName -replace '^.+?,(?=(OU|CN)=)'}},
                @{n = "AcceptMessagesOnlyFrom" ; e = {($_.AcceptMessagesOnlyFrom | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "AcceptMessagesOnlyFromDLMembers" ; e = {($_.AcceptMessagesOnlyFromDLMembers | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "AcceptMessagesOnlyFromSendersOrMembers" ; e = {($_.AcceptMessagesOnlyFromSendersOrMembers | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "AddressListMembership" ; e = {($_.AddressListMembership | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "AdministrativeUnits" ; e = {($_.AdministrativeUnits | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "BypassModerationFromSendersOrMembers" ; e = {($_.BypassModerationFromSendersOrMembers | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "GeneratedOfflineAddressBooks" ; e = {($_.GeneratedOfflineAddressBooks | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "GrantSendOnBehalfTo" ; e = {($_.GrantSendOnBehalfTo | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "ModeratedBy" ; e = {($_.ModeratedBy | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "RejectMessagesFrom" ; e = {($_.RejectMessagesFrom | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "RejectMessagesFromDLMembers" ; e = {($_.RejectMessagesFromDLMembers | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "RejectMessagesFromSendersOrMembers" ; e = {($_.RejectMessagesFromSendersOrMembers | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "PersistedCapabilities" ; e = {($_.PersistedCapabilities | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "AuditAdmin" ; e = {($_.AuditAdmin | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "AuditDelegate" ; e = {($_.AuditDelegate | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "AuditOwner" ; e = {($_.AuditOwner | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "MailboxProvisioningPreferences" ; e = {($_.MailboxProvisioningPreferences | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "UserCertificate" ; e = {($_.UserCertificate | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "UserSMimeCertificate" ; e = {($_.UserSMimeCertificate | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "Languages" ; e = {($_.Languages | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "AggregatedMailboxGuids" ; e = {($_.AggregatedMailboxGuids | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "ArchiveName" ; e = {($_.ArchiveName | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "ExtensionCustomAttribute1" ; e = {($_.ExtensionCustomAttribute1 | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "ExtensionCustomAttribute2" ; e = {($_.ExtensionCustomAttribute2 | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "ExtensionCustomAttribute3" ; e = {($_.ExtensionCustomAttribute3 | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "ExtensionCustomAttribute4" ; e = {($_.ExtensionCustomAttribute4 | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "ExtensionCustomAttribute5" ; e = {($_.ExtensionCustomAttribute5 | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "Extensions" ; e = {($_.Extensions | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "InPlaceHolds" ; e = {($_.InPlaceHolds | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "MailTipTranslations" ; e = {($_.MailTipTranslations | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "ObjectClass" ; e = {($_.ObjectClass | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "PoliciesExcluded" ; e = {($_.PoliciesExcluded | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "PoliciesIncluded" ; e = {($_.PoliciesIncluded | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "ProtocolSettings" ; e = {($_.ProtocolSettings | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "ResourceCustom" ; e = {($_.ResourceCustom | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "UMDtmfMap" ; e = {($_.UMDtmfMap | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "EmailAddresses" ; e = {($_.EmailAddresses | Where-Object {$_ -ne $null}) -join '|' }},
                @{n = "x500" ; e = {"x500:" + $_.LegacyExchangeDN}},
                @{n = "MailboxLocations" ; e = {($_.MailboxLocations | Where-Object {$_ -ne $null}) -join ";" }}
            )
        }
        else {
            $Selectproperties = @(
                'Name', 'RecipientTypeDetails', 'DisplayName', 'UserPrincipalName', 'Identity', 'PrimarySmtpAddress', 'Alias', 'OrganizationalUnit'
                'ForwardingAddress', 'ForwardingSmtpAddress', 'LitigationHoldDate', 'AccountDisabled', 'DeliverToMailboxAndForward'
                'HiddenFromAddressListsEnabled', 'IsDirSynced', 'LitigationHoldEnabled', 'LitigationHoldDuration'
                'LitigationHoldOwner', 'Office', 'RetentionPolicy', 'WindowsEmailAddress'
            )

            $CalculatedProps = @(
                @{n = "ArchiveName" ; e = {($_.ArchiveName | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "AcceptMessagesOnlyFrom" ; e = {($_.AcceptMessagesOnlyFrom | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "AcceptMessagesOnlyFromDLMembers" ; e = {($_.AcceptMessagesOnlyFromDLMembers | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "AcceptMessagesOnlyFromSendersOrMembers" ; e = {($_.AcceptMessagesOnlyFromSendersOrMembers | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "RejectMessagesFrom" ; e = {($_.RejectMessagesFrom | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "RejectMessagesFromDLMembers" ; e = {($_.RejectMessagesFromDLMembers | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "RejectMessagesFromSendersOrMembers" ; e = {($_.RejectMessagesFromSendersOrMembers | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "InPlaceHolds" ; e = {($_.InPlaceHolds | Where-Object {$_ -ne $null}) -join ";" }},
                @{n = "x500" ; e = {"x500:" + $_.LegacyExchangeDN}},
                @{n = "EmailAddresses" ; e = {($_.EmailAddresses | Where-Object {$_ -ne $null}) -join '|' }}
            )
        }
    }
    Process {
        if ($MailboxFilter) {
            foreach ($CurMailboxFilter in $MailboxFilter) {
                if (! $ArchivesOnly) {
                    Get-Mailbox -Filter $CurMailboxFilter -ResultSize unlimited | Select-Object ($Selectproperties + $CalculatedProps)
                    Get-RemoteMailbox -Filter $CurMailboxFilter -ResultSize unlimited | Select-Object ($Selectproperties + $CalculatedProps)
                }
                else {
                    Get-Mailbox -Archive -Filter $CurMailboxFilter -ResultSize unlimited | Select-Object ($Selectproperties + $CalculatedProps)
                    Get-RemoteMailbox -Archive -Filter $CurMailboxFilter -ResultSize unlimited | Select-Object ($Selectproperties + $CalculatedProps)
                }
            }
        }
        else {
            if (! $ArchivesOnly) {
                Get-Mailbox -ResultSize unlimited | Select-Object ($Selectproperties + $CalculatedProps)
                Get-RemoteMailbox -ResultSize unlimited | Select-Object ($Selectproperties + $CalculatedProps)
            }
            else {
                Get-Mailbox -Archive -ResultSize unlimited | Select-Object ($Selectproperties + $CalculatedProps)
                Get-RemoteMailbox -Archive -ResultSize unlimited | Select-Object ($Selectproperties + $CalculatedProps)
            }
        }
    }
    End {

    }
}