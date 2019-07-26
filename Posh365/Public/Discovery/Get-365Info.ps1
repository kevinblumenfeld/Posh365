function Get-365Info {
    <#
    .SYNOPSIS
    Controller function for gathering information from an Office 365 tenant

    .DESCRIPTION
    Controller function for gathering information from an Office 365 tenant

    All multivalued attributes are expanded for proper output

    If using the -Filtered switch, it will be necessary to replace domain placeholders in script (e.g. contoso.com etc.)
    The filters can be adjusted to anything supported by the -Filter parameter (OPath filters)

    .EXAMPLE
    Get-365Info -Tenant CONTOSO -Verbose

    .EXAMPLE
    Get-365Info -Tenant CONTOSO -Filtered -Verbose

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Tenant,

        [Parameter(Mandatory)]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $ComplianceOnly,

        [Parameter()]
        [switch]
        $Filtered,

        [Parameter()]
        [switch]
        $SkipLicensingReport,

        [Parameter()]
        [switch]
        $SkipPermissionsReport,

        [Parameter()]
        [switch]
        $StartAtMailboxes,

        [Parameter()]
        [switch]
        $DontExportToExcel

    )
    end {
        $TenantPath = Join-Path $Path $Tenant
        $DetailedTenantPath = Join-Path  $TenantPath 'Detailed'
        $ItemSplat = @{
            Type        = 'Directory'
            Force       = $true
            ErrorAction = 'SilentlyContinue'
        }
        $null = New-Item @ItemSplat -Path $TenantPath
        $null = New-Item @ItemSplat -Path $DetailedTenantPath

        $ExportCSVSplat = @{
            NoTypeInformation = $true
            Encoding          = 'UTF8'
        }

        $MsolUserProperties = @(
            'DisplayName', 'UserPrincipalName', 'Title', 'FirstName', 'LastName', 'StreetAddress'
            'City', 'State', 'PostalCode', 'Country', 'PhoneNumber', 'Fax', 'Department'
            'Office', 'LastDirSyncTime', 'IsLicensed', 'ProxyAddresses'
        )
        $MSOLGroupProperties = @(
            'DisplayName', 'GroupType', 'Description', 'EmailAddress', 'ManagedBy'
            'LastDirSyncTime', 'proxyAddresses', 'CommonName'
        )

        $EXORecipientProperties = @(
            'DisplayName', 'RecipientTypeDetails', 'Office', 'Alias', 'Identity', 'PrimarySmtpAddress'
            'WindowsLiveID', 'LitigationHoldEnabled', 'Name', 'EmailAddresses'
        )
        $EXOGroupProperties = @(
            'DisplayName', 'Alias', 'GroupType', 'Identity', 'PrimarySmtpAddress', 'RecipientTypeDetails'
            'WindowsEmailAddress', 'AcceptMessagesOnlyFromSendersOrMembers', 'ManagedBy', 'EmailAddresses', 'x500'
            'Name', 'membersName', 'membersSMTP'
        )
        $EXOMailboxProperties = @(
            'DisplayName', 'Office', 'RecipientTypeDetails', 'AccountDisabled', 'IsDirSynced', 'MailboxGB'
            'ArchiveGB', 'DeletedGB', 'TotalGB', 'LastLogonTime', 'ItemCount', 'ArchiveState', 'ArchiveStatus'
            'ArchiveName', 'MaxReceiveSize', 'MaxSendSize', 'ActiveSyncEnabled', 'OWAEnabled', 'ECPEnabled'
            'PopEnabled', 'ImapEnabled', 'MAPIEnabled', 'EwsEnabled', 'RecipientLimits', 'AcceptMessagesOnlyFrom'
            'AcceptMessagesOnlyFromDLMembers', 'ForwardingAddress', 'ForwardingSmtpAddress', 'DeliverToMailboxAndForward'
            'UserPrincipalName', 'PrimarySmtpAddress', 'Identity', 'AddressBookPolicy', 'Guid', 'LitigationHoldEnabled'
            'LitigationHoldDuration', 'LitigationHoldOwner', 'InPlaceHolds', 'x500', 'EmailAddresses'
        )
        $EXOArchiveMailboxProperties = @(
            'Name', 'RecipientTypeDetails', 'DisplayName', 'UserPrincipalName', 'Identity', 'PrimarySmtpAddress', 'Alias'
            'ForwardingAddress', 'ForwardingSmtpAddress', 'LitigationHoldDate', 'AccountDisabled', 'DeliverToMailboxAndForward'
            'HiddenFromAddressListsEnabled', 'IsDirSynced', 'LitigationHoldEnabled', 'LitigationHoldDuration'
            'LitigationHoldOwner', 'Office', 'RetentionPolicy', 'WindowsEmailAddress', 'ArchiveName', 'AcceptMessagesOnlyFrom'
            'AcceptMessagesOnlyFromDLMembers', 'AcceptMessagesOnlyFromSendersOrMembers', 'RejectMessagesFrom'
            'RejectMessagesFromDLMembers', 'RejectMessagesFromSendersOrMembers', 'InPlaceHolds', 'x500', 'EmailAddresses'
        )
        $EXOMailContactsProperties = @(
            'DisplayName', 'PrimarySmtpAddress', 'WindowsEmailAddress', 'ExternalEmailAddress', 'EmailAddresses'
            'RecipientTypeDetails', 'RecipientType', 'ArbitrationMailbox', 'LastExchangeChangedTime', 'MailTip'
            'EmailAddressPolicyEnabled', 'HasPicture', 'HasSpokenName', 'HiddenFromAddressListsEnabled', 'IsDirSynced'
            'IsValid', 'ModerationEnabled', 'RequireSenderAuthenticationEnabled', 'UsePreferMessageFormat', 'WhenChanged'
            'WhenChangedUTC', 'WhenCreated', 'WhenCreatedUTC', 'Guid', 'Alias', 'CustomAttribute1', 'CustomAttribute10'
            'CustomAttribute11', 'CustomAttribute12', 'CustomAttribute13', 'CustomAttribute14', 'CustomAttribute15'
            'CustomAttribute2', 'CustomAttribute3', 'CustomAttribute4', 'CustomAttribute5', 'CustomAttribute6'
            'CustomAttribute7', 'CustomAttribute8', 'CustomAttribute9', 'ExternalDirectoryObjectId', 'Id', 'Identity'
            'LegacyExchangeDN', 'MaxReceiveSize', 'MaxRecipientPerMessage', 'MaxSendSize', 'MessageBodyFormat'
            'MessageFormat', 'Name', 'SendModerationNotifications', 'SimpleDisplayName', 'UseMapiRichTextFormat'
            'AcceptMessagesOnlyFrom', 'AcceptMessagesOnlyFromDLMembers', 'AcceptMessagesOnlyFromSendersOrMembers'
            'AddressListMembership', 'AdministrativeUnits', 'BypassModerationFromSendersOrMembers', 'GrantSendOnBehalfTo'
            'ModeratedBy', 'RejectMessagesFrom', 'RejectMessagesFromDLMembers', 'RejectMessagesFromSendersOrMembers'
            'UserCertificate', 'UserSMimeCertificate', 'ExtensionCustomAttribute1', 'ExtensionCustomAttribute2'
            'ExtensionCustomAttribute3', 'ExtensionCustomAttribute4', 'ExtensionCustomAttribute5', 'Extensions'
            'MailTipTranslations', 'PoliciesExcluded', 'PoliciesIncluded', 'UMDtmfMap', 'DistinguishedName'
        )
        $EXORetentionPoliciesProperties = @(
            'PolicyName', 'TagType', 'TagName', 'TagAgeLimit', 'TagAction', 'TagEnabled', 'IsDefault', 'RetentionPolicyID'
        )
        $EXOOrganizationRelationshipProperties = @(
            'Id', 'DomainNames', 'FreeBusyAccessEnabled', 'FreeBusyAccessLevel', 'FreeBusyAccessScope'
            'MailboxMoveEnabled', 'MailboxMoveCapability', 'OAuthApplicationId', 'DeliveryReportEnabled'
            'MailTipsAccessEnabled', 'MailTipsAccessLevel', 'MailTipsAccessScope', 'PhotosEnabled'
            'TargetApplicationUri', 'TargetSharingEpr', 'TargetOwaURL', 'TargetAutodiscoverEpr'
            'OrganizationContact', 'Enabled', 'ArchiveAccessEnabled', 'AdminDisplayName', 'ExchangeVersion'
            'Name', 'DistinguishedName', 'Identity', 'ObjectCategory', 'WhenChanged', 'WhenCreated'
            'WhenChangedUTC', 'WhenCreatedUTC', 'ExchangeObjectId', 'Guid', 'IsValid', 'ObjectState'
        )
        $EXORemoteDomainsProperties = @(
            'DomainName', 'IsInternal', 'TargetDeliveryDomain', 'AllowedOOFType', 'AutoReplyEnabled', 'AutoForwardEnabled'
            'DeliveryReportEnabled', 'NDREnabled', 'MeetingForwardNotificationEnabled', 'ContentType', 'DisplaySenderName'
            'PreferredInternetCodePageForShiftJis', 'RequiredCharsetCoverage', 'TNEFEnabled', 'LineWrapSize'
            'TrustedMailOutboundEnabled', 'TrustedMailInboundEnabled', 'UseSimpleDisplayName', 'NDRDiagnosticInfoEnabled'
            'MessageCountThreshold', 'Name', 'Identity', 'WhenChanged', 'WhenCreated', 'WhenChangedUTC', 'WhenCreatedUTC'
            'ExchangeObjectId', 'Id', 'Guid', 'IsValid', 'ObjectState', 'DistinguishedName', 'ByteEncoderTypeFor7BitCharsets'
            'CharacterSet', 'NonMimeCharacterSet'
        )
        $ComplianceDLPPoliciesProperties = @(
            'Name', 'Mode', 'Type', 'Workload', 'ExchangeLocation', 'SharePointLocation', 'SharePointLocationException'
            'OneDriveLocation', 'OneDriveLocationException', 'ExchangeOnPremisesLocation', 'SharePointOnPremisesLocation'
            'SharePointOnPremisesLocationException', 'TeamsLocation', 'TeamsLocationException', 'ExchangeSender'
            'ExchangeSenderMemberOf', 'ExchangeSenderException', 'ExchangeSenderMemberOfException', 'ExtendedProperties'
            'Priority', 'ObjectVersion', 'CreatedBy', 'LastModifiedBy', 'ReadOnly', 'ExternalIdentity', 'Comment', 'Enabled'
            'DistributionStatus', 'DistributionResults', 'LastStatusUpdateTime', 'ModificationTimeUtc', 'CreationTimeUtc'
            'Identity', 'Id', 'IsValid', 'ExchangeVersion', 'DistinguishedName', 'ObjectCategory', 'ObjectClass', 'WhenChanged'
            'WhenCreated', 'WhenChangedUTC', 'WhenCreatedUTC', 'ExchangeObjectId', 'OrganizationId', 'Guid', 'OriginatingServer'
            'ObjectState'
        )
        $ComplianceRetentionPoliciesProperties = @(
            'Name', 'TeamsPolicy', 'SharePointLocation', 'SharePointLocationException', 'RetentionRuleTypes', 'ExchangeLocation'
            'ExchangeLocationException', 'PublicFolderLocation', 'SkypeLocation', 'SkypeLocationException', 'ModernGroupLocation'
            'ModernGroupLocationException', 'OneDriveLocation', 'OneDriveLocationException', 'TeamsChatLocation'
            'TeamsChatLocationException', 'TeamsChannelLocation', 'TeamsChannelLocationException', 'DynamicScopeLocation'
            'RestrictiveRetention', 'Workload', 'Priority', 'ObjectVersion', 'CreatedBy', 'LastModifiedBy', 'ReadOnly'
            'ExternalIdentity', 'Comment', 'Enabled', 'Mode', 'DistributionStatus', 'DistributionResults', 'LastStatusUpdateTime'
            'ModificationTimeUtc', 'CreationTimeUtc', 'Identity', 'Id', 'IsValid', 'ExchangeVersion', 'DistinguishedName'
            'WhenChanged', 'WhenCreated', 'WhenChangedUTC', 'WhenCreatedUTC', 'ExchangeObjectId', 'OrganizationId', 'Guid', 'ObjectState'
        )
        $ComplianceAlertPoliciesProperties = @(
            'Name', 'Filter', 'Operation', 'LogicalOperationName', 'NotificationEnabled', 'NotifyUser', 'Severity', 'Threshold'
            'TimeWindow', 'NotifyUserOnFilterMatch', 'MergedRuleXml', 'StreamType', 'ThreatType', 'AlertBy', 'AlertFor', 'AlertScenario'
            'Scenario', 'NotifyUserThrottleThreshold', 'NotifyUserThrottleWindow', 'NotifyUserSuppressionExpiryDate', 'NotificationCulture'
            'AggregationType', 'Category', 'IsSystemRule', 'ReadOnly', 'ExternalIdentity', 'ImmutableId', 'Priority', 'Workload', 'Policy'
            'Comment', 'Disabled', 'Mode', 'ObjectVersion', 'CreatedBy', 'LastModifiedBy', 'Guid', 'Identity', 'Id', 'IsValid'
            'ExchangeVersion', 'DistinguishedName', 'ObjectCategory', 'ObjectClass', 'WhenChanged', 'WhenCreated', 'WhenChangedUTC'
            'WhenCreatedUTC', 'ExchangeObjectId', 'OrganizationId', 'OriginatingServer', 'ObjectState'
        )
        $365_Sku = (Join-Path $TenantPath '365_Sku.csv')
        $MSOL_Upn = (Join-Path $TenantPath 'MSOL_Upn.csv')
        $MSOL_Users = (Join-Path $TenantPath 'MSOL_Users.csv')
        $MSOL_Groups = (Join-Path $TenantPath 'MSOL_Groups.csv')
        $MSOL_Groups_Type = (Join-Path $TenantPath 'MSOL_GroupType.csv')
        $MSOL_Users_Detailed = (Join-Path $DetailedTenantPath 'MSOL_Users_Detailed.csv')

        $EXO_MailContacts = (Join-Path $TenantPath 'EXO_MailContacts.csv')
        $EXO_Recipients = (Join-Path $TenantPath 'EXO_Recipients.csv')
        $EXO_RecipientEmails = (Join-Path $TenantPath 'EXO_RecipientEmails.csv')
        $EXO_Groups = (Join-Path $TenantPath 'EXO_Groups.csv')
        $EXO_GroupMembers = (Join-Path $TenantPath 'EXO_GroupMembers.csv')
        $EXO_GroupMembersSMTP = (Join-Path $TenantPath 'EXO_GroupMembersSMTP.csv')
        $EXO_Mailboxes = (Join-Path $TenantPath 'EXO_Mailboxes.csv')
        $EXO_MailboxEmails = (Join-Path $TenantPath 'EXO_MailboxEmails.csv')
        $EXO_ArchiveMailboxes = (Join-Path $TenantPath 'EXO_ArchiveMailboxes.csv')
        $EXO_ResourceMailboxes = (Join-Path $TenantPath 'EXO_ResourceMailboxes.csv')
        $EXO_RetentionPolicies = (Join-Path $TenantPath 'EXO_RetentionPolicies.csv')
        $EXO_AcceptedDomains = (Join-Path $TenantPath 'EXO_AcceptedDomains.csv')
        $EXO_RemoteDomains = (Join-Path $TenantPath 'EXO_RemoteDomains.csv')
        $EXO_OrganizationConfig = (Join-Path $TenantPath 'EXO_OrganizationConfig.csv')
        $EXO_OrganizationRelationship = (Join-Path $TenantPath 'EXO_OrganizationRelationship.csv')
        $EXO_Recipients_Detailed = (Join-Path $DetailedTenantPath 'EXO_Recipients_Detailed.csv')
        $EXO_Groups_Detailed = (Join-Path $DetailedTenantPath 'EXO_Groups_Detailed.csv')
        $EXO_Mailboxes_Detailed = (Join-Path $DetailedTenantPath 'EXO_Mailboxes_Detailed.csv')
        $EXO_ArchiveMailboxes_Detailed = (Join-Path $DetailedTenantPath 'EXO_ArchiveMailboxes_Detailed.csv')

        $EOP_ConnectionFilters = (Join-Path $TenantPath 'EOP_ConnectionFilters.csv')
        $EOP_AntiSpamPolicies = (Join-Path $TenantPath 'EOP_AntiSpamPolicies.csv')
        $EOP_AntiSpamRules = (Join-Path $TenantPath 'EOP_AntiSpamRules.csv')
        $EOP_OutboundAntiSpam = (Join-Path $TenantPath 'EOP_OutboundAntiSpam.csv')

        $Compliance_DLPPolicies = (Join-Path $TenantPath 'Compliance_DLPPolicies.csv')
        $Compliance_RetentionPolicies = (Join-Path $TenantPath 'Compliance_RetentionPolicies.csv')
        $Compliance_AlertPolicies = (Join-Path $TenantPath 'Compliance_AlertPolicies.csv')

        $365_UnifiedGroups = (Join-Path $DetailedTenantPath '365_UnifiedGroups.csv')

        if (-not $ComplianceOnly) {
            if (-not $Filtered) {
                if (-not $StartAtMailboxes) {
                    Write-Verbose "Gathering Retention Polices and linked Retention Policy Tags"
                    Get-RetentionLinks | Select-Object $EXORetentionPoliciesProperties |
                    Export-Csv $EXO_RetentionPolicies @ExportCSVSplat

                    Write-Verbose "Gathering Office 365 Unified Groups"
                    Export-AndImportUnifiedGroups -Mode Export -File $365_UnifiedGroups

                    Write-Verbose "Gathering Connection Filters"
                    Get-HostedConnectionFilterPolicy | Export-Csv $EOP_ConnectionFilters @ExportCSVSplat

                    Write-Verbose "Gathering Content Filter Policies"
                    Get-HostedContentFilterPolicy | Export-Csv $EOP_AntiSpamPolicies @ExportCSVSplat

                    Write-Verbose "Gathering Content Filter Rules"
                    Get-HostedContentFilterRule | Export-Csv $EOP_AntiSpamRules @ExportCSVSplat

                    Write-Verbose "Gathering Outbound Spam Filter Policies"
                    Get-HostedOutboundSpamFilterPolicy | Export-Csv $EOP_OutboundAntiSpam @ExportCSVSplat

                    Write-Verbose "Gathering Accepted Domains"
                    $SelectDomain = @('Name', 'DomainName', 'DomainType', 'Default', 'AuthenticationType')
                    Get-AcceptedDomain | Select-Object $SelectDomain | Export-Csv $EXO_AcceptedDomains @ExportCSVSplat

                    Write-Verbose "Gathering Remote Domains"
                    Get-RemoteDomain | Select-Object $EXORemoteDomainsProperties |
                    Export-Csv $EXO_RemoteDomains @ExportCSVSplat

                    Write-Verbose "Gathering Organization Config"
                    (Get-OrganizationConfig).PSObject.Properties | Select-Object Name, Value
                    Export-Csv $EXO_OrganizationConfig @ExportCSVSplat

                    Write-Verbose "Gathering Organization Relationship"
                    Get-OrganizationRelationship | Select-Object $EXOOrganizationRelationshipProperties |
                    Export-Csv $EXO_OrganizationRelationship @ExportCSVSplat

                    Write-Verbose "Gathering Mail Contacts"
                    Get-EXOMailContact | Select-Object $EXOMailContactsProperties |
                    Export-Csv $EXO_MailContacts @ExportCSVSplat

                    Write-Verbose "Gathering MsolGroups"
                    Get-365MsolGroup | Select-Object $MSOLGroupProperties | Export-Csv $MSOL_Groups @ExportCSVSplat

                    Write-Verbose "Gathering Distribution & Mail-Enabled Security Groups"
                    Get-EXOGroup -DetailedReport | Export-Csv $EXO_Groups_Detailed @ExportCSVSplat
                    Import-Csv $EXO_Groups_Detailed | Select-Object $EXOGroupProperties | Export-Csv $EXO_Groups @ExportCSVSplat
                }
                Write-Verbose "Gathering Exchange Online Mailboxes"
                Get-EXOMailbox -DetailedReport | Export-Csv $EXO_Mailboxes_Detailed @ExportCSVSplat
                Import-Csv $EXO_Mailboxes_Detailed | Select-Object $EXOMailboxProperties | Export-Csv $EXO_Mailboxes @ExportCSVSplat

                Write-Verbose "Gathering Exchange Online Archive Mailboxes"
                Get-EXOMailbox -ArchivesOnly -DetailedReport | Export-Csv $EXO_ArchiveMailboxes_Detailed @ExportCSVSplat
                Import-Csv $EXO_ArchiveMailboxes_Detailed | Select-Object $EXOArchiveMailboxProperties | Export-Csv $EXO_ArchiveMailboxes @ExportCSVSplat

                Write-Verbose "Gathering Exchange Online Resource Mailboxes and Calendar Processing"
                $ResourceMailbox = Import-Csv $EXO_Mailboxes_Detailed | Where-Object { $_.RecipientTypeDetails -in 'RoomMailbox', 'EquipmentMailbox' }
                Get-EXOResourceMailbox -ResourceMailbox $ResourceMailbox | Export-Csv $EXO_ResourceMailboxes @ExportCSVSplat

                Import-Csv $EXO_Groups | Export-MembersOnePerLine -ReportPath $TenantPath -FindInColumn MembersName |
                Export-Csv $EXO_GroupMembers @ExportCSVSplat

                Import-Csv $EXO_Groups | Export-MembersOnePerLine -ReportPath $TenantPath -FindInColumn MembersSMTP |
                Export-Csv $EXO_GroupMembersSMTP @ExportCSVSplat

                Import-Csv $EXO_Mailboxes_Detailed | Export-EmailsOnePerLine -ReportPath $TenantPath -FindInColumn EmailAddresses |
                Export-Csv $EXO_MailboxEmails @ExportCSVSplat

                Write-Verbose "Gathering Recipients"
                Get-365Recipient -DetailedReport | Export-Csv $EXO_Recipients_Detailed @ExportCSVSplat
                Import-Csv $EXO_Recipients_Detailed | Select-Object $EXORecipientProperties | Export-Csv $EXO_Recipients @ExportCSVSplat

                Import-Csv $EXO_Recipients | Export-EmailsOnePerLine -ReportPath $TenantPath -FindInColumn EmailAddresses |
                Export-Csv $EXO_RecipientEmails @ExportCSVSplat

                Write-Verbose "Gathering MsolUsers"
                Get-365MsolUser -DetailedReport | Export-Csv $MSOL_Users_Detailed @ExportCSVSplat
                Import-Csv $MSOL_Users_Detailed | Select-Object $MsolUserProperties | Export-Csv $MSOL_Users @ExportCSVSplat

                Get-MsolAccountSku | Select-Object @(
                    @{
                        Name       = 'Sku'
                        Expression = { ($_.AccountSkuId -split ':')[1] }
                    }
                    @{
                        Name       = 'Active'
                        Expression = 'ActiveUnits'
                    }
                    @{
                        Name       = 'Consumed'
                        Expression = 'ConsumedUnits'
                    }
                ) | Sort-Object -Property consumed -Descending | Export-Csv $365_Sku @ExportCSVSplat

                $Result = [System.Collections.Generic.List[PSObject]]::New()
                $UPN = Import-Csv $MSOL_Users_Detailed | Where-Object { $_.userprincipalname -notlike "*#EXT*" } | Select-Object @(
                    @{
                        Name       = 'UserPrincipalName'
                        Expression = { ($_.userprincipalname -split '@')[1] }
                    }
                )
                $Result.Add($UPN)
                $EXTUPN = Import-Csv $MSOL_Users_Detailed | Where-Object { $_.userprincipalname -like "*#EXT*" } | Select-Object @(
                    @{
                        Name       = 'UserPrincipalName'
                        Expression = { [regex]::match($_.UserPrincipalName, '#[\s\S]*$').captures.groups[0] }
                    }
                )
                $Result.Add($EXTUPN)
                ($Result).UserPrincipalName | Group-Object | Select-Object name, count |
                Sort-Object -Property count -Descending | Export-Csv $MSOL_Upn @ExportCSVSplat

                Import-Csv $MSOL_Groups | Select-Object GroupType | Group-Object -Property GroupType | Select-Object Name, Count |
                Sort-Object -Property Count -Descending | Export-Csv $MSOL_Groups_Type @ExportCSVSplat

                if (-not $SkipLicensingReport) {
                    Write-Verbose "Gathering Office 365 Licenses"
                    Get-CloudLicense -Path $TenantPath
                }
                if (-not $SkipPermissionsReport) {
                    Write-Verbose "Gathering Mailbox Delegate Permissions"
                    Get-EXOMailboxPerms -Path $DetailedTenantPath

                    'EXO_FullAccess.csv', 'EXO_SendOnBehalf.csv', 'EXO_SendAs.csv' | ForEach-Object {
                        Import-Csv (Join-Path $DetailedTenantPath $_) -ErrorAction SilentlyContinue | Where-Object { $_ } |
                        Export-Csv (Join-Path $TenantPath 'EXO_Permissions.csv') -NoTypeInformation -Append }

                    Write-Verbose "Gathering Distribution Group Delegate Permissions"
                    Get-EXODGPerms -Path $DetailedTenantPath

                    'EXO_DGSendOnBehalf.csv', 'EXO_DGSendAs.csv' | ForEach-Object {
                        Import-Csv (Join-Path $DetailedTenantPath $_) -ErrorAction SilentlyContinue | Where-Object { $_ } |
                        Export-Csv (Join-Path $TenantPath 'EXO_DGPermissions.csv') -NoTypeInformation -Append }
                }
            }
            else {
                Write-Verbose "Gathering 365 Recipients - filtered"
                '{UserPrincipalName -like "*contoso.com" -or
            emailaddresses -like "*contoso.com" -or
            ExternalEmailAddress -like "*contoso.com" -or
            PrimarySmtpAddress -like "*contoso.com"}' | Get-365Recipient -DetailedReport | Export-Csv $EXO_Recipients_Detailed @ExportCSVSplat
                Import-Csv $EXO_Recipients_Detailed | Select-Object $EXORecipientProperties | Export-Csv $EXO_Recipients @ExportCSVSplat

                Write-Verbose "Gathering MsolUsers - filtered"
                'contoso.com' | Get-365MsolUser -DetailedReport | Export-Csv $MSOL_Users_Detailed @ExportCSVSplat
                Import-Csv $MSOL_Users_Detailed | Select-Object $MsolUserProperties | Export-Csv $MSOL_Users @ExportCSVSplat

                Write-Verbose "Gathering MsolGroups - filtered"
                Get-MsolGroup -All | Where-Object { $_.proxyaddresses -like "*contoso.com" } | Select-Object -ExpandProperty ObjectId | Get-365MsolGroup | Export-Csv $MSOL_Groups @ExportCSVSplat

                Write-Verbose "Gathering Distribution & Mail-Enabled Security Groups - filtered"
                Get-DistributionGroup -Filter "emailaddresses -like '*contoso.com*'" -ResultSize Unlimited | Select-Object -ExpandProperty Name | Get-EXOGroup -DetailedReport | Export-Csv $EXO_Groups_Detailed @ExportCSVSplat
                Import-Csv $EXO_Groups_Detailed | Select-Object $EXOGroupProperties | Export-Csv $EXO_Groups @ExportCSVSplat

                Write-Verbose "Gathering Exchange Online Mailboxes - filtered"
                '{emailaddresses -like "*contoso.com"}' | Get-EXOMailbox -DetailedReport | Export-Csv $EXO_Mailboxes_Detailed @ExportCSVSplat
                Import-Csv $EXO_Mailboxes_Detailed | Select-Object $EXOMailboxProperties | Export-Csv $EXO_Mailboxes @ExportCSVSplat

                Write-Verbose "Gathering Exchange Online Archive Mailboxes - filtered"
                '{emailaddresses -like "*contoso.com"}' | Get-EXOMailbox -ArchivesOnly -DetailedReport | Export-Csv $EXO_ArchiveMailboxes_Detailed @ExportCSVSplat
                Import-Csv $EXO_ArchiveMailboxes_Detailed | Select-Object $EXOMailboxProperties | Export-Csv $EXO_ArchiveMailboxes @ExportCSVSplat

                Write-Verbose "Gathering Exchange Online Resource Mailboxes and Calendar Processing"
                '{emailaddresses -like "*contoso.com"}' | Get-EXOResourceMailbox | Export-Csv $EXO_ResourceMailboxes @ExportCSVSplat

                if (-not $SkipLicensingReport) {
                    Write-Verbose "Gathering Office 365 Licenses - filtered"
                    'contoso.com' | Get-CloudLicense
                }
                if (-not $SkipPermissionsReport) {
                    Write-Verbose "Gathering Mailbox Delegate Permissions - filtered"
                    Get-Recipient -Filter { EmailAddresses -like "*contoso.com" } -ResultSize Unlimited |
                    Select-Object -ExpandProperty name | Get-EXOMailboxPerms -Path $TenantPath

                    Write-Verbose "Gathering Distribution Group Delegate Permissions - filtered"
                    Get-Recipient -Filter { EmailAddresses -like "*contoso.com" } -ResultSize Unlimited |
                    Select-Object -ExpandProperty name | Get-EXODGPerms -Path $TenantPath
                }
            }
        }
        else {
            Write-Verbose "Gathering DLP Compliance Policies"
            Get-DlpCompliancePolicy -DistributionDetail | Select-Object $ComplianceDLPPoliciesProperties |
            Export-Csv $Compliance_DLPPolicies @ExportCSVSplat

            Write-Verbose "Gathering Compliance Retention Policies"
            Get-RetentionCompliancePolicy -DistributionDetail | Select-Object $ComplianceRetentionPoliciesProperties |
            Export-Csv $Compliance_RetentionPolicies @ExportCSVSplat

            Write-Verbose "Gathering Compliance Alert Policies"
            Get-ProtectionAlert | Select-Object $ComplianceAlertPoliciesProperties |
            Export-Csv $Compliance_AlertPolicies @ExportCSVSplat
        }
        if (-not $DontExportToExcel) {
            $ExcelSplat = @{
                Path                    = (Join-Path $TenantPath '365_Discovery.xlsx')
                TableStyle              = 'Medium2'
                FreezeTopRowFirstColumn = $true
                AutoSize                = $true
                BoldTopRow              = $false
                ClearSheet              = $true
                ErrorAction             = 'SilentlyContinue'
            }
            Get-ChildItem $TenantPath -Filter *.csv | Sort-Object BaseName -Descending | ForEach-Object {
                Import-Csv $_.fullname | Export-Excel @ExcelSplat -WorksheetName $_.basename }
        }
    }
}

