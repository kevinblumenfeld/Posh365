function Get-EXOnlineMailbox {
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
    Get-EXOnlineMailbox | Export-Csv c:\scripts\All365Mailboxes.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    Get-EXOnlineMailbox -ArchivesOnly | Export-Csv c:\scripts\All365Mailboxes.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    '{emailaddresses -like "*contoso.com"}' | Get-EXOnlineMailbox | Export-Csv c:\scripts\365Mailboxes.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    '{emailaddresses -like "*contoso.com"}' | Get-EXOnlineMailbox -ArchivesOnly | Export-Csv c:\scripts\365Mailboxes.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    '{emailaddresses -like "*contoso.com"}' | Get-EXOnlineMailbox -DetailedReport | Export-Csv c:\scripts\365Mailboxes_Detailed.csv -notypeinformation -encoding UTF8

    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $DetailedReport,

        [Parameter()]
        [switch]
        $ArchivesOnly,

        [Parameter(ValueFromPipeline)]
        [string[]]
        $MailboxFilter
    )
    begin {
        $EXOArchiveMin = @{
            ResultSize   = 'unlimited'
            PropertySets = @('Archive', 'Minimum')
            Verbose      = $false
        }
        if ($DetailedReport) {
            $CasHash = @{ }
            $CasList = Get-EXOCASMailbox -ResultSize Unlimited -Verbose:$false
            foreach ($Cas in $CasList) {
                $CasHash[$Cas.PrimarySmtpAddress] = @{
                    ActiveSyncEnabled = $Cas.ActiveSyncEnabled
                    OWAEnabled        = $Cas.OWAEnabled
                    ECPEnabled        = $Cas.ECPEnabled
                    PopEnabled        = $Cas.PopEnabled
                    ImapEnabled       = $Cas.ImapEnabled
                    MAPIEnabled       = $Cas.MAPIEnabled
                    EwsEnabled        = $Cas.EwsEnabled
                }
            }
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
                @{n = "MailboxGB" ; e = { $StatsHash.($_.PrimarySmtpAddress).MailboxGB } }
                @{n = "ArchiveGB" ; e = { $StatsHash.($_.PrimarySmtpAddress).ArchiveGB } }
                @{n = "DeletedGB" ; e = { $StatsHash.($_.PrimarySmtpAddress).DeletedGB } }
                @{n = "TotalGB" ; e = { $StatsHash.($_.PrimarySmtpAddress).TotalGB } }
                @{n = "LastLogonTime" ; e = { $StatsHash.($_.PrimarySmtpAddress).LastLogonTime } }
                @{n = "ItemCount" ; e = { $StatsHash.($_.PrimarySmtpAddress).ItemCount } }
                @{n = "ActiveSyncEnabled" ; e = { $CasHash.($_.PrimarySmtpAddress).ActiveSyncEnabled } }
                @{n = "OWAEnabled" ; e = { $CasHash.($_.PrimarySmtpAddress).OWAEnabled } }
                @{n = "ECPEnabled" ; e = { $CasHash.($_.PrimarySmtpAddress).ECPEnabled } }
                @{n = "PopEnabled" ; e = { $CasHash.($_.PrimarySmtpAddress).PopEnabled } }
                @{n = "ImapEnabled" ; e = { $CasHash.($_.PrimarySmtpAddress).ImapEnabled } }
                @{n = "MAPIEnabled" ; e = { $CasHash.($_.PrimarySmtpAddress).MAPIEnabled } }
                @{n = "EwsEnabled" ; e = { $CasHash.($_.PrimarySmtpAddress).EwsEnabled } }
                @{n = "AcceptMessagesOnlyFrom" ; e = { @($_.AcceptMessagesOnlyFrom) -ne '' -join '|' } },
                @{n = "AcceptMessagesOnlyFromDLMembers" ; e = { @($_.AcceptMessagesOnlyFromDLMembers) -ne '' -join '|' } },
                @{n = "AcceptMessagesOnlyFromSendersOrMembers" ; e = { @($_.AcceptMessagesOnlyFromSendersOrMembers) -ne '' -join '|' } },
                @{n = "AddressListMembership" ; e = { @($_.AddressListMembership) -ne '' -join '|' } },
                @{n = "AdministrativeUnits" ; e = { @($_.AdministrativeUnits) -ne '' -join '|' } },
                @{n = "BypassModerationFromSendersOrMembers" ; e = { @($_.BypassModerationFromSendersOrMembers) -ne '' -join '|' } },
                @{n = "GeneratedOfflineAddressBooks" ; e = { @($_.GeneratedOfflineAddressBooks) -ne '' -join '|' } },
                @{n = "GrantSendOnBehalfTo" ; e = { @($_.GrantSendOnBehalfTo) -ne '' -join '|' } },
                @{n = "ModeratedBy" ; e = { @($_.ModeratedBy) -ne '' -join '|' } },
                @{n = "RejectMessagesFrom" ; e = { @($_.RejectMessagesFrom) -ne '' -join '|' } },
                @{n = "RejectMessagesFromDLMembers" ; e = { @($_.RejectMessagesFromDLMembers) -ne '' -join '|' } },
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
                'Name', 'RecipientTypeDetails', 'DisplayName', 'UserPrincipalName', 'Identity', 'PrimarySmtpAddress', 'Alias'
                'ForwardingAddress', 'ForwardingSmtpAddress', 'LitigationHoldDate', 'AccountDisabled', 'DeliverToMailboxAndForward'
                'HiddenFromAddressListsEnabled', 'IsDirSynced', 'LitigationHoldEnabled', 'LitigationHoldDuration'
                'LitigationHoldOwner', 'Office', 'RetentionPolicy', 'WindowsEmailAddress'
            )
            $CalculatedProps = @(
                @{n = "ArchiveName" ; e = { ($_.ArchiveName | Where-Object { $_ -ne $null }) -join ";" } },
                @{n = "AcceptMessagesOnlyFrom" ; e = { @($_.AcceptMessagesOnlyFrom) -ne '' -join '|' } },
                @{n = "AcceptMessagesOnlyFromDLMembers" ; e = { @($_.AcceptMessagesOnlyFromDLMembers) -ne '' -join '|' } },
                @{n = "AcceptMessagesOnlyFromSendersOrMembers" ; e = { @($_.AcceptMessagesOnlyFromSendersOrMembers) -ne '' -join '|' } },
                @{n = "RejectMessagesFrom" ; e = { @($_.RejectMessagesFrom) -ne '' -join '|' } },
                @{n = "RejectMessagesFromDLMembers" ; e = { @($_.RejectMessagesFromDLMembers) -ne '' -join '|' } },
                @{n = "RejectMessagesFromSendersOrMembers" ; e = { @($_.RejectMessagesFromSendersOrMembers) -ne '' -join '|' } },
                @{n = "PersistedCapabilities" ; e = { @($_.PersistedCapabilities) -ne '' -join '|' } },
                @{n = "InPlaceHolds" ; e = { @($_.InPlaceHolds) -ne '' -join '|' } },
                @{n = "EmailAddresses" ; e = { @($_.EmailAddresses) -ne '' -join '|' } },
                @{n = "x500" ; e = { "x500:" + $_.LegacyExchangeDN } }
            )
        }
    }
    process {
        if ($MailboxFilter) {
            foreach ($CurMailboxFilter in $MailboxFilter) {
                if (-not $ArchivesOnly) {
                    Get-EXOMailbox -Filter $CurMailboxFilter @EXOArchiveMin | Select-Object ($Selectproperties + $CalculatedProps)
                }
                else {
                    Get-EXOMailbox -Archive -Filter $CurMailboxFilter @EXOArchiveMin | Select-Object ($Selectproperties + $CalculatedProps)
                }
            }
        }
        else {
            if (-not $ArchivesOnly) {
                Write-Verbose "Gathering All Mailboxes Initially"
                $MailboxList = Get-EXOMailbox @EXOArchiveMin
                Write-Host "`nTotal Mailboxes Found: $($MailboxList.count)" -ForegroundColor Green

                $ConfirmCount = Read-Host "Do you want to split the count?:(y/n)"

                if ($ConfirmCount -eq 'y') {
                    Write-Host "You need the 'StartNumber' and 'EndNumber' to split the accounts" -ForegroundColor Yellow
                    Write-Host "################## FOR EXAMPLE ##############################"
                    Write-Host "If you want to run for first 1000 users"
                    Write-Host "Enter 'StartNumber' as '0' and 'EndNumber' as '999'`n"
                    Write-Host "If you want to run for second 1000 users"
                    Write-Host "Enter 'StartNumber' as '1000' and 'EndNumber' as '1999' and so on...`n"
                    Write-Host "#############################################################`n"
                    $StartNumber = Read-Host "Enter StartNumber"
                    $EndNumber = Read-Host "Enter EndNumber"
                    Write-Host "`n"
                    $MailboxList = $MailboxList[$StartNumber..$EndNumber]
                }
                if ($ConfirmCount -eq 'n' -or $ConfirmCount -eq 'y') {
                    $StatsHash = @{ }
                    foreach ($Mailbox in $MailboxList) {
                        Write-Host "Mailbox:`t$($Mailbox.DisplayName)" -ForegroundColor White
                        $Stat = $Mailbox | Get-ExchangeMailboxStatistics
                        if ($Stat) {
                            $StatsHash.Add(($Stat.PrimarySmtpAddress), @{
                                    DisplayName       = $Stat.DisplayName
                                    UserPrincipalName = $Stat.UserPrincipalName
                                    MailboxGB         = $Stat.MailboxGB
                                    ArchiveGB         = $Stat.ArchiveGB
                                    DeletedGB         = $Stat.DeletedGB
                                    TotalGB           = $Stat.TotalGB
                                    LastLogonTime     = $Stat.LastLogonTime
                                    ItemCount         = $Stat.ItemCount
                                })
                        }
                    }
                }
                $MailboxList | Select-Object ($Selectproperties + $CalculatedProps)
            }
            else {
                Get-EXOMailbox -Archive @EXOArchiveMin | Select-Object ($Selectproperties + $CalculatedProps)
            }
        }
    }
    end {

    }
}

