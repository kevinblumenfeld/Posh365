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
        $Compliance,

        [Parameter()]
        [switch]
        $LicensingReport,

        [Parameter()]
        [switch]
        $PermissionsReport,

        [Parameter()]
        [switch]
        $FolderPermissionReport,

        [Parameter()]
        [switch]
        $ExchangeOnline,

        [Parameter()]
        [switch]
        $MSOnline,

        [Parameter()]
        [switch]
        $AzureAD,

        [Parameter()]
        [switch]
        $DontIncludeUnifiedGroupsInAllEmailsReport,

        [Parameter()]
        [switch]
        $CreateExcel,

        [Parameter()]
        [switch]
        $SkipMailboxReport,

        [Parameter()]
        [switch]
        $SkipDistributionGroupReport,

        [Parameter()]
        [switch]
        $SkipUnifiedGroupsReport,

        [Parameter()]
        [switch]
        $CreateMSPCompleteBulkFile
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
        $MSOLUserProperties = @(
            'DisplayName', 'UserPrincipalName', 'Title', 'FirstName', 'LastName', 'StreetAddress'
            'City', 'State', 'PostalCode', 'BlockCredential', 'Country', 'PhoneNumber', 'Fax'
            'Department', 'Office', 'LastDirSyncTime', 'IsLicensed', 'ProxyAddresses'
        )
        $MSOLUserMFAProperties = @(
            'DisplayName', 'BlockCredential', 'MFA_State', 'UserPrincipalName', 'DefaultMethod', 'Methods'
            'MethodChoice', 'Auth_AlternatePhoneNumber', 'Auth_Email', 'Auth_OldPin'
            'Auth_PhoneNumber', 'Auth_Pin', 'Country', 'Department', 'Title', 'PhoneNumber'
            'MobilePhone'
        )
        $MSOLGroupProperties = @(
            'DisplayName', 'GroupType', 'Description', 'EmailAddress', 'ManagedBy'
            'LastDirSyncTime', 'proxyAddresses', 'CommonName'
        )
        $EXOAcceptedDomainProperties = @(
            'Name', 'DomainName', 'DomainType', 'Default', 'AuthenticationType'
        )
        $EXORecipientProperties = @(
            'DisplayName', 'RecipientTypeDetails', 'Office', 'Alias', 'Identity', 'PrimarySmtpAddress'
            'WindowsLiveID', 'LitigationHoldEnabled', 'Name', 'EmailAddresses', 'ExchangeObjectId'
        )
        $EXOGroupProperties = @(
            'DisplayName', 'Alias', 'GroupType', 'IsDirSynced', 'PrimarySmtpAddress', 'RecipientTypeDetails'
            'WindowsEmailAddress', 'AcceptMessagesOnlyFromSendersOrMembers', 'RequireSenderAuthenticationEnabled'
            'ManagedBy', 'EmailAddresses', 'x500', 'Name', 'membersName', 'membersSMTP', 'Identity', 'ExchangeObjectId'
        )
        $EXOMailboxProperties = @(
            'DisplayName', 'Office', 'RecipientTypeDetails', 'AccountDisabled', 'IsDirSynced', 'MailboxGB'
            'ArchiveGB', 'DeletedGB', 'TotalGB', 'LastLogonTime', 'ItemCount', 'ArchiveState', 'ArchiveStatus'
            'ArchiveName', 'MaxReceiveSize', 'MaxSendSize', 'ActiveSyncEnabled', 'OWAEnabled', 'ECPEnabled'
            'PopEnabled', 'ImapEnabled', 'MAPIEnabled', 'EwsEnabled', 'RecipientLimits', 'AcceptMessagesOnlyFrom'
            'AcceptMessagesOnlyFromDLMembers', 'ForwardingAddress', 'ForwardingSmtpAddress', 'DeliverToMailboxAndForward'
            'UserPrincipalName', 'PrimarySmtpAddress', 'Identity', 'AddressBookPolicy', 'Guid', 'LitigationHoldEnabled'
            'LitigationHoldDuration', 'LitigationHoldOwner', 'InPlaceHolds', 'x500', 'EmailAddresses', 'ExchangeObjectId'
        )
        $EXOContactsProperties = @(
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
            'MailTipTranslations', 'PoliciesExcluded', 'PoliciesIncluded', 'UMDtmfMap', 'DistinguishedName', 'ExchangeObjectId'
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
            'WhenCreated', 'WhenChangedUTC', 'WhenCreatedUTC', 'ExchangeObjectId', 'Guid', 'OriginatingServer'
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
            'WhenChanged', 'WhenCreated', 'WhenChangedUTC', 'WhenCreatedUTC', 'ExchangeObjectId', 'Guid', 'ObjectState'
        )
        $ComplianceAlertPoliciesProperties = @(
            'Name', 'Filter', 'Operation', 'LogicalOperationName', 'NotificationEnabled', 'NotifyUser', 'Severity', 'Threshold'
            'TimeWindow', 'NotifyUserOnFilterMatch', 'MergedRuleXml', 'StreamType', 'ThreatType', 'AlertBy', 'AlertFor', 'AlertScenario'
            'Scenario', 'NotifyUserThrottleThreshold', 'NotifyUserThrottleWindow', 'NotifyUserSuppressionExpiryDate', 'NotificationCulture'
            'AggregationType', 'Category', 'IsSystemRule', 'ReadOnly', 'ExternalIdentity', 'ImmutableId', 'Priority', 'Workload', 'Policy'
            'Comment', 'Disabled', 'Mode', 'ObjectVersion', 'CreatedBy', 'LastModifiedBy', 'Guid', 'Identity', 'Id', 'IsValid'
            'ExchangeVersion', 'DistinguishedName', 'ObjectCategory', 'ObjectClass', 'WhenChanged', 'WhenCreated', 'WhenChangedUTC'
            'WhenCreatedUTC', 'ExchangeObjectId', 'OriginatingServer', 'ObjectState'
        )
        $MSOL_Spn = (Join-Path $TenantPath 'MSOL_Spn.csv')
        $MSOL_Upn = (Join-Path $TenantPath 'MSOL_Upn.csv')
        $MSOL_Users = (Join-Path $TenantPath 'MSOL_Users.csv')
        $MSOL_MFAUsers = (Join-Path $TenantPath 'MSOL_MFAUsers.csv')
        $MSOL_Roles = (Join-Path $TenantPath 'MSOL_Roles.csv')
        $MSOL_Groups = (Join-Path $TenantPath 'MSOL_Groups.csv')
        $MSOL_Groups_Type = (Join-Path $TenantPath 'MSOL_GroupTypes.csv')
        $MSOL_Users_Detailed = (Join-Path $DetailedTenantPath 'MSOL_Users_Detailed.csv')

        $AzureAD_Roles = (Join-Path $TenantPath 'AzureAD_Roles.csv')
        $AzureAD_Users = (Join-Path $DetailedTenantPath 'AzureAD_Users.csv')
        $AzureAD_Guests = (Join-Path $DetailedTenantPath 'AzureAD_Guests.csv')
        $AzureAD_Devices = (Join-Path $TenantPath 'AzureAD_Devices.csv')

        $EXO_TransportRules_Detailed = (Join-Path $DetailedTenantPath 'EXO_TransportRules_Detailed.csv')
        $EXO_TransportRuleCollection = (Join-Path $DetailedTenantPath 'EXO_TransportRuleCollection.xml')
        $EXO_TransportRules = (Join-Path $TenantPath 'EXO_TransportRules.csv')
        $EXO_OutboundConnectors = (Join-Path $TenantPath 'EXO_OutboundConnectors.csv')
        $EXO_InboundConnectors = (Join-Path $TenantPath 'EXO_InboundConnectors.csv')
        $EXO_Roles = (Join-Path $TenantPath 'EXO_Roles.csv')
        $EXO_Contacts = (Join-Path $TenantPath 'EXO_Contacts.csv')
        $EXO_ContactsSync = (Join-Path $DetailedTenantPath 'EXO_ContactsSync.csv')
        $EXO_Recipients = (Join-Path $TenantPath 'EXO_Recipients.csv')
        $EXO_RecipientTypes = (Join-Path $TenantPath 'EXO_RecipientTypes.csv')
        $EXO_RecipientEmails = (Join-Path $TenantPath 'EXO_RecipientEmails.csv')
        $EXO_RecipientDomains = (Join-Path $TenantPath 'EXO_RecipientDomains.csv')
        $EXO_Groups = (Join-Path $TenantPath 'EXO_Groups.csv')
        $EXO_GroupsSync = (Join-Path $DetailedTenantPath 'EXO_GroupsSync.csv')
        $EXO_GroupMembers = (Join-Path $TenantPath 'EXO_GroupMembers.csv')
        $EXO_GroupMembersSMTP = (Join-Path $TenantPath 'EXO_GroupMembersSMTP.csv')
        $EXO_Mailboxes = (Join-Path $TenantPath 'EXO_Mailboxes.csv')
        $EXO_MailboxTypes = (Join-Path $TenantPath 'EXO_MailboxTypes.csv')
        $EXO_Emails = (Join-Path $TenantPath 'EXO_Emails.csv')
        $EXO_Domains = (Join-Path $TenantPath 'EXO_Domains.csv')
        $EXO_MailboxesSync = (Join-Path $DetailedTenantPath 'EXO_MailboxesSync.csv')
        $EXO_ResourceMailboxes = (Join-Path $TenantPath 'EXO_ResourceMailboxes.csv')
        $EXO_RetentionPolicies = (Join-Path $TenantPath 'EXO_RetentionPolicies.csv')
        $EXO_AcceptedDomains = (Join-Path $TenantPath 'EXO_AcceptedDomains.csv')
        $EXO_RemoteDomains = (Join-Path $TenantPath 'EXO_RemoteDomains.csv')
        $EXO_OrganizationConfig = (Join-Path $TenantPath 'EXO_OrganizationConfig.csv')
        $EXO_OrganizationRelationship = (Join-Path $TenantPath 'EXO_OrganizationRelationship.csv')
        $EXO_Recipients_Detailed = (Join-Path $DetailedTenantPath 'EXO_Recipients_Detailed.csv')
        $EXO_Groups_Detailed = (Join-Path $DetailedTenantPath 'EXO_Groups_Detailed.csv')
        $EXO_Mailboxes_Detailed = (Join-Path $DetailedTenantPath 'EXO_Mailboxes_Detailed.csv')
        $EXO_Permissions = (Join-Path $TenantPath 'EXO_Permissions.csv')
        $EXO_FolderPermissions = (Join-Path $TenantPath 'EXO_FolderPermissions.csv')
        $EXO_PermissionsDG = (Join-Path $TenantPath 'EXO_DGPermissions.csv')
        $EXO_DirSyncCount = (Join-Path $TenantPath 'EXO_DirSyncCount.csv')
        $EXO_AllRecipientEmails = (Join-Path $DetailedTenantPath 'EXO_AllRecipientEmails.csv')
        $365_AllEmails = (Join-Path $TenantPath '365_AllEmails.csv')
        # $EXO_UniqueEmails = (Join-Path $DetailedTenantPath 'EXO_UniqueEmails.csv')

        $EOP_ConnectionFilters = (Join-Path $TenantPath 'EOP_ConnectionFilters.csv')
        $EOP_ContentPolicy = (Join-Path $TenantPath 'EOP_ContentPolicy.csv')
        $EOP_ContentRule = (Join-Path $TenantPath 'EOP_ContentRules.csv')
        $EOP_OutboundSpamPolicy = (Join-Path $TenantPath 'EOP_OutboundSpamPolicy.csv')
        $EOP_OutboundSpamRule = (Join-Path $TenantPath 'EOP_OutboundSpamRules.csv')
        $EOP_OutboundSpamPolicy = (Join-Path $TenantPath 'EOP_OutboundSpamPolicy.csv')

        $Compliance_Roles = (Join-Path $TenantPath 'Compliance_Roles.csv')
        $Compliance_DLPPolicies = (Join-Path $TenantPath 'Compliance_DLPPolicies.csv')
        $Compliance_RetentionPolicies = (Join-Path $TenantPath 'Compliance_RetentionPolicies.csv')
        $Compliance_AlertPolicies = (Join-Path $TenantPath 'Compliance_AlertPolicies.csv')

        $365_UnifiedGroups = (Join-Path $TenantPath '365_UnifiedGroups.csv')
        $365_UnifiedGroupReport = (Join-Path $TenantPath '365_UnifiedGroupReport.csv')
        $365_Sku = (Join-Path $TenantPath '365_Skus.csv')
        $365_LicenseOptions = (Join-Path $TenantPath '365_LicenseOptions.csv')

        $MSP_BulkFile = (Join-Path $TenantPath 'Batches.csv')

        switch ($true) {
            { $MSOnline } {
                Write-Verbose "Gathering Internal Domains Matching Azure AD Service Principal Names"
                Get-DomainMatchingServicePrincipal | Export-Csv $MSOL_Spn @ExportCSVSplat

                Write-Verbose "Gathering MsolUsers"
                Get-365MsolUser -DetailedReport | Export-Csv $MSOL_Users_Detailed @ExportCSVSplat
                $MsolUserDetailedImport = Import-Csv $MSOL_Users_Detailed | Where-Object { $_.UserPrincipalName -notmatch "FederatedEmail" -and $_.DisplayName -notmatch "SystemMailbox{" }
                $MsolUserDetailedImport | Select-Object $MsolUserProperties | Sort-Object DisplayName | Export-Csv $MSOL_Users @ExportCSVSplat

                Write-Verbose "Gathering MsolUsers MFA Report"
                $MsolUserDetailedImport | Where-Object { $_.UserPrincipalName -notmatch "#EXT#" -and $_.UserPrincipalName -notmatch "FederatedEmail" } |
                Select-Object $MsolUserMFAProperties | Sort-Object DisplayName | Export-Csv $MSOL_MFAUsers @ExportCSVSplat

                Write-Verbose "Gathering MsolUser Roles Report"
                Get-MsolRoleReport | Sort-Object Role, DisplayName | Export-Csv $MSOL_Roles @ExportCSVSplat

                Write-Verbose "Gathering MsolGroups"
                Get-365MsolGroup | Select-Object $MSOLGroupProperties |
                Sort-Object DisplayName | Export-Csv $MSOL_Groups @ExportCSVSplat

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
                ) | Sort-Object -Property Consumed -Descending | Export-Csv $365_Sku @ExportCSVSplat
                $EA = $ErrorActionPreference
                $ErrorActionPreference = "SilentlyContinue"
                $Result = [System.Collections.Generic.List[PSObject]]::New()
                $UPN = $MsolUserDetailedImport | Where-Object { $_.userprincipalname -notlike "*#EXT*" } | Select-Object @(
                    @{
                        Name       = 'UserPrincipalName'
                        Expression = { ($_.userprincipalname -split '@')[1] }
                    }
                )
                $Result.AddRange([PSObject[]]$UPN)
                $EXTUPN = $MsolUserDetailedImport | Where-Object { $_.userprincipalname -like "*#EXT*" } | Select-Object @(
                    @{
                        Name       = 'UserPrincipalName'
                        Expression = { [regex]::match($_.UserPrincipalName, '#[\s\S]*$').captures.groups[0] }
                    }
                )
                $Result.AddRange([PSObject[]]$EXTUPN)
                ($Result).UserPrincipalName | Group-Object | Select-Object name, count |
                Sort-Object -Property count -Descending | Export-Csv $MSOL_Upn @ExportCSVSplat

                Import-Csv $MSOL_Groups | Select-Object GroupType | Group-Object -Property GroupType | Select-Object Name, Count |
                Sort-Object -Property Count -Descending | Export-Csv $MSOL_Groups_Type @ExportCSVSplat

            }
            { -not $MSOnline } {
                $MsolUserDetailedImport = Import-Csv $MSOL_Users_Detailed -ErrorAction SilentlyContinue
            }
            { $MsolUserDetailedImport } {
                $MFAHash = Get-MsolUserMFAHash -MsolUserList $MsolUserDetailedImport
            }
            { $AzureAD } {

                Write-Verbose "Gathering AzureAD Roles"
                If ($MFAHash) {
                    Get-AzureADRoleReport -MFAHash $MFAHash | Export-Csv $AzureAD_Roles @ExportCSVSplat
                }
                else {
                    Get-AzureADRoleReport | Export-Csv $AzureAD_Roles @ExportCSVSplat
                }
                Write-Verbose "Gathering AzureAD Users and Guest Users"
                $AzureADDetails = Get-AzureActiveDirectoryUser
                $AzureADDetails | Export-Csv $AzureAD_Users @ExportCSVSplat
                $AzureADGuests = $AzureADDetails | Where-Object { $_.UserType -eq 'Guest' }
                $AzureADGuests | Export-Csv $AzureAD_Guests @ExportCSVSplat

                $OnePerGuestProxy = Export-EmailsOnePerLineOneOff -FindInColumn ProxyAddresses -RowList ($AzureADGuests | Where-Object { $_.ProxyAddresses })
                $OnePerGuestMail = Export-EmailsOnePerLineOneOff -FindInColumn Mail -RowList ($AzureADGuests | Where-Object { $_.Mail } )
                $OnePerGuestOtherMails = Export-EmailsOnePerLineOneOff -FindInColumn OtherMails -RowList ($AzureADGuests | Where-Object { $_.OtherMails })
                Write-Verbose "Gathering AzureAD Devices"
                Get-AzureActiveDirectoryDevice | Export-Csv $AzureAD_Devices @ExportCSVSplat
                'placeholder' | Invoke-SetCloudLicense -DisplayTenantsSkusAndOptionsFriendlyNames -ErrorAction SilentlyContinue | Select-Object @(
                    'Group5'
                    'Group4'
                    'Group3'
                    'Group2'
                    'Group1'
                    'Sku'
                    'Service'
                    'Remaining'
                    'Total'
                ) | Export-Csv $365_LicenseOptions @ExportCSVSplat

            }
            { $ExchangeOnline } {
                $EA = $ErrorActionPreference
                $ErrorActionPreference = "SilentlyContinue"
                Write-Verbose "Gathering Exchange Transport Rules"
                $TransportCollection = Export-TransportRuleCollection
                Set-Content -Path $EXO_TransportRuleCollection -Value $TransportCollection.FileData -Encoding Byte
                [xml]$TRuleColList = Get-Content $EXO_TransportRuleCollection

                Get-TransportRuleReport | Export-Csv $EXO_TransportRules_Detailed @ExportCSVSplat
                $TransportData = Import-Csv $EXO_TransportRules_Detailed
                $TransportHash = Get-TransportRuleHash -TransportData $TransportData
                $TransportCsv = Convert-TransportXMLtoCSV -TRuleColList $TRuleColList -TransportHash $TransportHash
                $TransportCsv | Sort-Object Name | Export-Csv $EXO_TransportRules @ExportCSVSplat

                Write-Verbose "Gathering Exchange Roles"
                if ($MFAHash) {
                    Get-ExchangeRoleReport -MFAHash $MFAHash | Sort-Object Role | Export-Csv $EXO_Roles @ExportCSVSplat
                }
                else {
                    Get-ExchangeRoleReport | Sort-Object Role | Export-Csv $EXO_Roles @ExportCSVSplat
                }
                Write-Verbose "Gathering Inbound Connectors"
                Get-InboundConnectorReport | Sort-Object Name | Export-Csv $EXO_InboundConnectors @ExportCSVSplat

                Write-Verbose "Gathering Outbound Connectors"
                Get-OutboundConnectorSummary | Sort-Object Name | Export-Csv $EXO_OutboundConnectors @ExportCSVSplat

                Write-Verbose "Gathering Connection Filters"
                Get-EOPConnectionPolicy | Sort-Object Name | Export-Csv $EOP_ConnectionFilters @ExportCSVSplat

                Write-Verbose "Gathering Content Filter Policies"
                Get-EOPContentPolicy | Sort-Object Identity | Export-Csv $EOP_ContentPolicy @ExportCSVSplat

                Write-Verbose "Gathering Content Filter Rules"
                Get-EOPContentRule | Export-Csv $EOP_ContentRule @ExportCSVSplat

                Write-Verbose "Gathering Outbound Spam Filter Policies"
                Get-EOPOutboundSpamPolicy | Sort-Object Name | Export-Csv $EOP_OutboundSpamPolicy @ExportCSVSplat

                Write-Verbose "Gathering Outbound Spam Filter Rules"
                Get-EOPOutboundSpamRule | Export-Csv $EOP_OutboundSpamRule @ExportCSVSplat

                Write-Verbose "Gathering Retention Polices and linked Retention Policy Tags"
                Get-RetentionLinks | Select-Object $EXORetentionPoliciesProperties |
                Sort-Object PolicyName, TagType | Export-Csv $EXO_RetentionPolicies @ExportCSVSplat

                if (-not $SkipUnifiedGroupsReport) {
                    Write-Verbose "Gathering Office 365 Unified Groups"
                    Export-AndImportUnifiedGroups -Mode Export -File $365_UnifiedGroups
                    Write-Verbose "Gathering Office 365 Unified Group Emails, Members, Subscribers & Owners"
                    $UGDetails = Get-UnifiedGroupOwnersMembersSubscribers
                    $UGDetails | Export-Csv $365_UnifiedGroupReport @ExportCSVSplat
                }

                if (-not $DontIncludeUnifiedGroupsInAllEmailsReport) {
                    $OnePerUGOwners = Export-EmailsOnePerLine -FindInColumn Owners -RowList ($UGDetails | Where-Object { $_.Owners })
                    $OnePerUGMember = Export-EmailsOnePerLine -FindInColumn Members -RowList ($UGDetails | Where-Object { $_.Members })
                    $OnePerUGSubscribers = Export-EmailsOnePerLine -FindInColumn Subscribers -RowList ($UGDetails | Where-Object { $_.Subscribers } )
                }
                Write-Verbose "Gathering Accepted Domains"
                Get-AcceptedDomain | Select-Object $EXOAcceptedDomainProperties |
                Sort-Object Name | Export-Csv $EXO_AcceptedDomains @ExportCSVSplat

                Write-Verbose "Gathering Remote Domains"
                Get-RemoteDomain | Select-Object $EXORemoteDomainsProperties |
                Sort-Object DomainName | Export-Csv $EXO_RemoteDomains @ExportCSVSplat

                Write-Verbose "Gathering Organization Config"
                (Get-OrganizationConfig).PSObject.Properties | Select-Object Name, Value |
                Export-Csv $EXO_OrganizationConfig @ExportCSVSplat

                Write-Verbose "Gathering Organization Relationship"
                Get-OrganizationRelationship | Select-Object $EXOOrganizationRelationshipProperties |
                Sort-Object Id | Export-Csv $EXO_OrganizationRelationship @ExportCSVSplat

                Write-Verbose "Gathering Mail Contacts"
                Get-EXOMailContact | Select-Object $EXOContactsProperties |
                Sort-Object DisplayName | Export-Csv $EXO_Contacts @ExportCSVSplat

                $ContactDetails = Import-Csv $EXO_Contacts
                $ContactDetails | Group-Object IsDirSynced | Select-Object name, count |
                Sort-Object -Property count -Descending | Export-Csv $EXO_ContactsSync @ExportCSVSplat

                if (-not $SkipDistributionGroupReport) {
                    Write-Verbose "Gathering Distribution & Mail-Enabled Security Groups"
                    Get-EXOGroup -DetailedReport | Export-Csv $EXO_Groups_Detailed @ExportCSVSplat
                }
                $EXOGroupsDetails = Import-Csv $EXO_Groups_Detailed
                $EXOGroupsDetails | Select-Object $EXOGroupProperties | Sort-Object DisplayName | Export-Csv $EXO_Groups @ExportCSVSplat

                $EXOGroupsDetails | Group-Object IsDirSynced | Select-Object name, count |
                Sort-Object -Property count -Descending | Export-Csv $EXO_GroupsSync @ExportCSVSplat

                if (-not $SkipMailboxReport) {
                    Write-Verbose "Gathering Exchange Online Mailboxes"
                    Get-EXOMailbox -DetailedReport | Export-Csv $EXO_Mailboxes_Detailed @ExportCSVSplat
                }
                $MailboxDetails = Import-Csv $EXO_Mailboxes_Detailed | Where-Object { $_.RecipientTypeDetails -ne 'DiscoveryMailbox' }
                $MailboxDetails | Select-Object $EXOMailboxProperties | Sort-Object DisplayName | Export-Csv $EXO_Mailboxes @ExportCSVSplat

                $MailboxDetails | Group-Object RecipientTypeDetails | Select-Object name, count |
                Sort-Object -Property count -Descending | Export-Csv $EXO_MailboxTypes @ExportCSVSplat

                $MailboxDetails | Group-Object IsDirSynced | Select-Object name, count |
                Sort-Object -Property count -Descending | Export-Csv $EXO_MailboxesSync @ExportCSVSplat

                Write-Verbose "Gathering Exchange Online Resource Mailboxes and Calendar Processing"
                $ResourceMailbox = $MailboxDetails | Where-Object { $_.RecipientTypeDetails -in 'RoomMailbox', 'EquipmentMailbox' }
                Get-EXOResourceMailbox -ResourceMailbox $ResourceMailbox | Sort-Object DisplayName | Export-Csv $EXO_ResourceMailboxes @ExportCSVSplat

                Import-Csv $EXO_Groups | Export-MembersOnePerLine -FindInColumn MembersName |
                Sort-Object DisplayName | Export-Csv $EXO_GroupMembers @ExportCSVSplat

                Import-Csv $EXO_Groups | Export-MembersOnePerLine -FindInColumn MembersSMTP |
                Sort-Object DisplayName | Export-Csv $EXO_GroupMembersSMTP @ExportCSVSplat

                $OnePerExoEmail = [System.Collections.Generic.List[PSObject]]::New()

                $OnePerMailbox = Export-EmailsOnePerLine -FindInColumn EmailAddresses -RowList $MailboxDetails

                $OnePerExoEmail.AddRange([PSObject[]]$OnePerMailbox)

                $OnePerContactExt = Export-EmailsOnePerLine -FindInColumn ExternalEmailAddress -RowList $ContactDetails

                $OnePerExoEmail.AddRange([PSObject[]]$OnePerContactExt)

                $OnePerContact = Export-EmailsOnePerLine -FindInColumn EmailAddresses -RowList $ContactDetails

                $OnePerExoEmail.AddRange([PSObject[]]$OnePerContact)

                $OnePerGroup = Export-EmailsOnePerLine -FindInColumn EmailAddresses -RowList $EXOGroupsDetails

                $OnePerExoEmail.AddRange([PSObject[]]$OnePerGroup)

                $OnePerExoEmail | Sort-Object DisplayName, RecipientTypeDetails | Export-Csv $EXO_Emails @ExportCSVSplat

                $OnePerExoEmail | Where-Object { $_.RecipientTypeDetails -ne 'DiscoveryMailbox' -and $_.Domain -and $_.Domain -notmatch "SPO_" } |
                Group-Object domain | Select-Object name, count | Sort-Object -Property count -Descending | Export-Csv $EXO_Domains @ExportCSVSplat

                $DirSyncCount = Get-ChildItem $DetailedTenantPath -Filter *sync.csv | ForEach-Object {
                    $BaseName = $_.BaseName
                    Import-Csv $_.FullName | Select-Object @(
                        @{
                            Name       = "ObjectType"
                            Expression = { [regex]::Matches(($BaseName), "(?<=EXO_).*?(?=Sync)").value }
                        }
                        @{
                            Name       = "IsDirSynced"
                            Expression = { $_.Name }
                        }
                        'Count'
                    )
                }

                $DirSyncCount | Export-Csv $EXO_DirSyncCount @ExportCSVSplat

                Write-Verbose "Gathering Recipients"
                Get-365Recipient -DetailedReport | Export-Csv $EXO_Recipients_Detailed @ExportCSVSplat
                $RecipientsDetails = Import-Csv $EXO_Recipients_Detailed | Where-Object { $_.RecipientTypeDetails -ne 'DiscoveryMailbox' }
                $RecipientsDetails | Sort-Object DisplayName | Select-Object $EXORecipientProperties | Export-Csv $EXO_Recipients @ExportCSVSplat

                $RecipientsDetails | Group-Object RecipientTypeDetails | Select-Object name, count |
                Sort-Object -Property count -Descending | Export-Csv $EXO_RecipientTypes @ExportCSVSplat

                $Recipients = Import-Csv $EXO_Recipients | Where-Object { $_.EmailAddresses }
                $OnePerRecipientEmail = Export-EmailsOnePerLine -FindInColumn EmailAddresses -RowList $Recipients | Sort-Object DisplayName
                $OnePerRecipientEmail | Export-Csv $EXO_RecipientEmails @ExportCSVSplat

                $OnePerAllEmail = [System.Collections.Generic.List[PSObject]]::New()

                if ($OnePerGuestOtherMails) {
                    $OnePerAllEmail.AddRange([PSObject[]]$OnePerGuestOtherMails)
                }
                if ($OnePerGuestProxy) {
                    $OnePerAllEmail.AddRange([PSObject[]]$OnePerGuestProxy)
                }
                if ($OnePerGuestMail) {
                    $OnePerAllEmail.AddRange([PSObject[]]$OnePerGuestMail)
                }
                $OnePerAllEmail.AddRange([PSObject[]]$OnePerContactExt)

                $OnePerAllEmail.AddRange([PSObject[]]$OnePerRecipientEmail)
                if (-not $DontIncludeUnifiedGroupsInAllEmailsReport) {
                    $OnePerAllEmail.AddRange([PSObject[]]$OnePerUGOwners)
                    $OnePerAllEmail.AddRange([PSObject[]]$OnePerUGMember)
                    $OnePerAllEmail.AddRange([PSObject[]]$OnePerUGSubscribers)
                }
                $OnePerAllEmail | Sort-Object DisplayName, RecipientTypeDetails | Export-Csv $365_AllEmails @ExportCSVSplat

                $OnePerRecipientEmail | Where-Object { $_.Domain -and $_.Domain -notmatch "SPO_" } |
                Group-Object Domain | Select-Object name, count | Sort-Object -Property count -Descending | Export-Csv $EXO_RecipientDomains @ExportCSVSplat

                # $AllEmails = [System.Collections.Generic.List[PSObject]]::New()

                # $Email = $OnePerExoEmail | Where-Object { $_.Address -and $_.Protocol -notmatch 'x500|SPO|x400' -and $_.RecipientTypeDetails -ne 'GuestMailUser' }
                # $AllEmails.AddRange([PSObject[]]$Email)

                $AllRecipientEmails = $OnePerRecipientEmail | Where-Object { $_.Address -and $_.Protocol -notmatch 'x500|SPO|x400' -and $_.RecipientTypeDetails -ne 'GuestMailUser' }
                # $AllEmails.AddRange([PSObject[]]$RecEmail)

                $AllRecipientEmails | Sort-Object -Property DisplayName | Export-Csv $EXO_AllRecipientEmails @ExportCSVSplat
                # $AllEmails | Sort-Object -Property Address -Unique | Select-Object Address | Export-Csv $EXO_UniqueEmails @ExportCSVSplat

                $ErrorActionPreference = $EA
            }
            { $LicensingReport } {
                Write-Verbose "Gathering Office 365 Licenses"
                Get-CloudLicense -Path $DetailedTenantPath
                $ColumnList = (Get-Content (Join-Path $DetailedTenantPath 365_Licenses.csv) | ForEach-Object { $_.split(',').count } | Sort-Object -Descending)[0]
                Import-Csv -Path (Join-Path $DetailedTenantPath 365_Licenses.csv) -Header (1..$ColumnList | ForEach-Object { "Column$_" }) |
                Export-Csv -Path (Join-Path $TenantPath 365_LicenseReport.csv) -NoTypeInformation
            }
            { $PermissionsReport } {
                Write-Verbose "Gathering Mailbox Delegate Permissions"
                Get-EXOMailboxPerms -Path $DetailedTenantPath

                'EXO_FullAccess.csv', 'EXO_SendOnBehalf.csv', 'EXO_SendAs.csv' | ForEach-Object {
                    Import-Csv (Join-Path $DetailedTenantPath $_) -ErrorAction SilentlyContinue | Where-Object { $_ } |
                    Export-Csv $EXO_Permissions -NoTypeInformation -Append }

                Write-Verbose "Gathering Distribution Group Delegate Permissions"
                Get-EXODGPerms $DetailedTenantPath

                'EXO_DGSendOnBehalf.csv', 'EXO_DGSendAs.csv' | ForEach-Object {
                    Import-Csv (Join-Path $DetailedTenantPath $_) -ErrorAction SilentlyContinue | Where-Object { $_ } |
                    Export-Csv $EXO_PermissionsDG -NoTypeInformation -Append }

            }
            { $FolderPermissionReport } {
                Write-Verbose "Gathering Folder Permissions"
                $MailboxDetails = Import-Csv $EXO_Mailboxes_Detailed | Where-Object { $_.RecipientTypeDetails -ne 'DiscoveryMailbox' }
                Write-Host "`nTotal Mailboxes Found: $($MailboxDetails.count)" -ForegroundColor Green

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
                    $MailboxDetails = $MailboxDetails[$StartNumber..$EndNumber]
                }
                if ($ConfirmCount -eq 'n' -or $ConfirmCount -eq 'y') {
                    Get-EXOMailboxFolderPerms -MailboxList $MailboxDetails | Export-Csv $EXO_FolderPermissions @ExportCSVSplat -Append
                }
            }

            { $Compliance } {
                Write-Verbose "Gathering Security and Compliance Roles"
                if ($MFAHash) {
                    Get-ComplianceRoleReport -MFAHash $MFAHash | Export-Csv $Compliance_Roles @ExportCSVSplat
                }
                else {
                    Get-ExchangeRoleReport | Export-Csv $Compliance_Roles @ExportCSVSplat
                }
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
            { $CreateExcel } {
                $EA = $ErrorActionPreference
                $ErrorActionPreference = "SilentlyContinue"
                $ExcelSplat = @{
                    Path                    = (Join-Path $TenantPath '365_Discovery.xlsx')
                    TableStyle              = 'Medium2'
                    FreezeTopRowFirstColumn = $true
                    AutoSize                = $true
                    BoldTopRow              = $false
                    ClearSheet              = $true
                    ErrorAction             = 'SilentlyContinue'
                }
                Get-ChildItem $TenantPath -Filter *.csv | Where-Object { $_.BaseName -ne '365_LicenseReport' } | Sort-Object BaseName -Descending |
                ForEach-Object { Import-Csv $_.fullname | Export-Excel @ExcelSplat -WorksheetName $_.basename }

                $Excel365Licenses = @{
                    Path                    = (Join-Path $TenantPath '365_Discovery.xlsx')
                    TableStyle              = 'Medium2'
                    FreezeTopRowFirstColumn = $true
                    AutoSize                = $true
                    BoldTopRow              = $false
                    ClearSheet              = $true
                    ErrorAction             = 'SilentlyContinue'
                    WorksheetName           = '365_Licenses'
                    ConditionalText         = $(
                        New-ConditionalText DisplayName White Black
                        New-ConditionalText UserPrincipalName White Black
                        New-ConditionalText AccountSku White Black
                    )
                }
                Import-Csv -Path (Join-Path $TenantPath 365_LicenseReport.csv) -ErrorAction SilentlyContinue | Export-Excel @Excel365Licenses
                $ErrorActionPreference = $EA
            }
            { $CreateMSPCompleteBulkFile } {
                $MsolHash = @{ }
                Import-Csv $MSOL_Users | ForEach-Object {
                    $MsolHash.Add($_.UserPrincipalName, @{
                            FirstName = $_.FirstName
                            LastName  = $_.LastName
                        })
                }
                $AzureADHash = @{ }
                Import-Csv $AzureAD_Users | ForEach-Object {
                    $AzureADHash.Add($_.UserPrincipalName, @{
                            DistinguishedName            = $_.DistinguishedName
                            OrganizationalUnit           = $_.OrganizationalUnit
                            'OrganizationalUnit(CN)'     = $_."OrganizationalUnit(CN)"
                            DirSyncEnabled               = [Bool]$_.DirSyncEnabled
                            OnPremisesSecurityIdentifier = $_.OnPremisesSecurityIdentifier
                        })
                }

                Import-Csv $EXO_Mailboxes | Select-Object @(
                    'DisplayName'
                    'Migrate'
                    'ArchiveOnly'
                    'DeploymentPro'
                    'DeploymentProMethod'
                    'LicenseGroup'
                    @{
                        Name       = 'DirSyncEnabled'
                        Expression = { $AzureADHash.$($_.UserPrincipalName).DirSyncEnabled }
                    }
                    'TargetMailboxInUse'
                    'RecipientTypeDetails'
                    'TotalGB'
                    'ArchiveGB'
                    @{
                        Name       = 'OrganizationalUnit(CN)'
                        Expression = { $AzureADHash.$($_.UserPrincipalName).'OrganizationalUnit(CN)' }
                    }
                    @{
                        Name       = 'SourcePrimary'
                        Expression = 'PrimarySmtpAddress'
                    }
                    @{
                        Name       = 'SourceTenantAddress'
                        Expression = { [regex]::matches(@(($_.EmailAddresses).split('|')), "(?<=(smtp|SMTP):)[^@]+@[^.]+?\.onmicrosoft\.com")[0].Value }
                    }
                    'TargetTenantAddress'
                    'TargetPrimary'
                    @{
                        Name       = 'FirstName'
                        Expression = { $MsolHash.$($_.UserPrincipalName).FirstName }
                    }
                    @{
                        Name       = 'LastName'
                        Expression = { $MsolHash.$($_.UserPrincipalName).LastName }
                    }
                    'UserPrincipalName'
                    @{
                        Name       = 'OnPremisesSecurityIdentifier'
                        Expression = { $AzureADHash.$($_.UserPrincipalName).OnPremisesSecurityIdentifier }
                    }
                    @{
                        Name       = 'DistinguishedName'
                        Expression = { $AzureADHash.$($_.UserPrincipalName).DistinguishedName }
                    }
                    'MailboxGB'
                    'DeletedGB'
                    'ArchiveStatus'
                    'Notes'
                    'BitTitanLicense'
                ) | Export-Csv $MSP_BulkFile @ExportCSVSplat
                $ExcelSplat = @{
                    Path                    = (Join-Path $TenantPath 'Batches.xlsx')
                    TableStyle              = 'Medium2'
                    FreezeTopRowFirstColumn = $true
                    AutoSize                = $true
                    BoldTopRow              = $false
                    ClearSheet              = $true
                    ErrorAction             = 'SilentlyContinue'
                }
                Import-Csv $MSP_BulkFile | Export-Excel @ExcelSplat -WorksheetName 'Batches'
            }
        }
    }
}
