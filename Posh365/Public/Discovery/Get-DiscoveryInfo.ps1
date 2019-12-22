Function Get-DiscoveryInfo {
    <#
    .SYNOPSIS
    On-Premises Active Directory discovery

    .EXAMPLE

    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (

    )

    try {
        Import-Module activedirectory -ErrorAction Stop -Verbose:$false
    }
    catch {
        Write-Host "This module depends on the ActiveDirectory module."
        Write-Host "Please download and install from https://www.microsoft.com/en-us/download/details.aspx?id=45520"
        throw
    }

    do {
        $Answer = Read-Host "Connect to Exchange Server? (Y/N)"
        if ($Answer -eq "Y") {
            $ServerName = Read-Host "Type the name of the Exchange Server and hit enter"
            Connect-Exchange -Server $ServerName
        }
    } until ($Answer -eq 'Y' -or $Answer -eq 'N')

    $RecipientProp = @(
        'DisplayName', 'RecipientTypeDetails', 'Office', 'Alias', 'Identity', 'PrimarySmtpAddress'
        'WindowsLiveID', 'LitigationHoldEnabled', 'Name', 'EmailAddresses', 'ExchangeObjectId'
    )
    $GroupProp = @(
        'DisplayName', 'Alias', 'GroupType', 'IsDirSynced', 'PrimarySmtpAddress', 'RecipientTypeDetails'
        'WindowsEmailAddress', 'AcceptMessagesOnlyFromSendersOrMembers', 'RequireSenderAuthenticationEnabled'
        'ManagedBy', 'EmailAddresses', 'x500', 'Name', 'membersName', 'membersSMTP', 'Identity', 'ExchangeObjectId'
        'LegacyExchangeDN'
    )
    $MailboxProp = @(
        'DisplayName', 'Office', 'RecipientTypeDetails', 'IsDirSynced', 'MailboxGB'
        'ArchiveGB', 'DeletedGB', 'TotalGB', 'LastLogonTime', 'ItemCount', 'ArchiveState', 'ArchiveStatus'
        'ArchiveName', 'MaxReceiveSize', 'MaxSendSize', 'ActiveSyncEnabled', 'OWAEnabled', 'ECPEnabled'
        'PopEnabled', 'ImapEnabled', 'MAPIEnabled', 'EwsEnabled', 'RecipientLimits', 'AcceptMessagesOnlyFrom'
        'AcceptMessagesOnlyFromDLMembers', 'ForwardingAddress', 'ForwardingSmtpAddress', 'DeliverToMailboxAndForward'
        'UserPrincipalName', 'PrimarySmtpAddress', 'Identity', 'AddressBookPolicy', 'Guid', 'LitigationHoldEnabled'
        'LitigationHoldDuration', 'LitigationHoldOwner', 'InPlaceHolds', 'x500', 'EmailAddresses', 'ExchangeObjectId'
    )
    $ContactProp = @(
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
        'MailTipTranslations', 'PoliciesExcluded', 'PoliciesIncluded', 'DistinguishedName', 'ExchangeObjectId'
    )
    $RetentionProp = @(
        'PolicyName', 'TagType', 'TagName', 'TagAgeLimit', 'TagAction', 'TagEnabled', 'IsDefault', 'RetentionPolicyID'
    )

    $AcceptedDomainsProp = @(
        'Name', 'DomainName', 'DomainType', 'Default', 'AuthenticationType'
    )
    $RemoteDomainsProp = @(
        'DomainName', 'IsInternal', 'TargetDeliveryDomain', 'AllowedOOFType', 'AutoReplyEnabled', 'AutoForwardEnabled'
        'DeliveryReportEnabled', 'NDREnabled', 'MeetingForwardNotificationEnabled', 'ContentType', 'DisplaySenderName'
        'PreferredInternetCodePageForShiftJis', 'RequiredCharsetCoverage', 'TNEFEnabled', 'LineWrapSize'
        'TrustedMailOutboundEnabled', 'TrustedMailInboundEnabled', 'UseSimpleDisplayName', 'NDRDiagnosticInfoEnabled'
        'MessageCountThreshold', 'Name', 'Identity', 'WhenChanged', 'WhenCreated', 'WhenChangedUTC', 'WhenCreatedUTC'
        'ExchangeObjectId', 'Id', 'Guid', 'IsValid', 'ObjectState', 'DistinguishedName', 'ByteEncoderTypeFor7BitCharsets'
        'CharacterSet', 'NonMimeCharacterSet'
    )
    $OrganizationRelationshipProp = @(
        'Id', 'DomainNames', 'FreeBusyAccessEnabled', 'FreeBusyAccessLevel', 'FreeBusyAccessScope'
        'MailboxMoveEnabled', 'MailboxMoveCapability', 'OAuthApplicationId', 'DeliveryReportEnabled'
        'MailTipsAccessEnabled', 'MailTipsAccessLevel', 'MailTipsAccessScope', 'PhotosEnabled'
        'TargetApplicationUri', 'TargetSharingEpr', 'TargetOwaURL', 'TargetAutodiscoverEpr'
        'OrganizationContact', 'Enabled', 'ArchiveAccessEnabled', 'AdminDisplayName', 'ExchangeVersion'
        'Name', 'DistinguishedName', 'Identity', 'ObjectCategory', 'WhenChanged', 'WhenCreated'
        'WhenChangedUTC', 'WhenCreatedUTC', 'ExchangeObjectId', 'Guid', 'IsValid', 'ObjectState'
    )

    $Discovery = Join-Path ([Environment]::GetFolderPath("Desktop")) -ChildPath 'Discovery'
    $Detailed = Join-Path $Discovery -ChildPath 'Detailed'
    $CSV = Join-Path $Discovery -ChildPath 'CSV'
    New-Item -ItemType Directory -Path $Discovery -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $Detailed -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $CSV -ErrorAction SilentlyContinue

    $CsvSplat = @{
        NoTypeInformation = $true
        Encoding          = 'UTF8'
    }

    ##########################
    #### ACTIVE DIRECTORY ####
    ##########################

    # AD User
    Write-Verbose "Retrieving Active Directory Users"
    Get-ADUser -Filter * -Properties * | Select-Object * | Export-Clixml -Path (Join-Path -Path $Detailed -ChildPath 'ADUsers.xml')
    Get-ActiveDirectoryUser -DetailedReport | Export-Csv @CSVSplat -Path (Join-Path -Path $Detailed -ChildPath 'ADUsers.csv')

    # AD Replication
    Write-Verbose "Retrieving Active Directory Replication"
    Get-ADReplication | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'ADReplication.csv')

    ##################
    #### EXCHANGE ####
    ##################

    # Exchange Receive Connectors
    Write-Verbose "Retrieving Exchange Receive Connectors"
    Get-ExchangeReceiveConnector | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'ReceiveConn.csv')

    # Exchange Send Connectors
    Write-Verbose "Retrieving Exchange Send Connectors"
    Get-ExchangeSendConnector | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'SendConn.csv')

    # Exchange Address Lists
    Write-Verbose "Retrieving Address Lists"
    Get-AddressList | Get-ExchangeAddressList | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'AddressLists.csv')

    Write-Verbose "Retrieving Global Address Lists"
    Get-GlobalAddressList | Get-ExchangeGlobalAddressList | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'GlobalAddressLists.csv')

    Write-Verbose "Retrieving Offline Address Books"
    Get-OfflineAddressBook | Get-ExchangeOfflineAddressBook | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'OfflineAddressBook.csv')

    Write-Verbose "Retrieving Address Book Policies"
    Get-AddressBookPolicy | Get-ExchangeAddressBookPolicy | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'AddressBookPolicies.csv')

    # Exchange Distribution Groups
    Write-Verbose "Retrieving Exchange Distribution Groups"
    Get-DistributionGroup | Select-Object * | Export-Clixml -Path (Join-Path -Path $Detailed -ChildPath 'ExchangeDistributionGroups.xml')
    $DistributionGroups = Get-ExchangeDistributionGroup -DetailedReport
    $DistributionGroups | Export-Csv @CSVSplat -Path (Join-Path -Path $Detailed -ChildPath 'ExchangeDistributionGroups.csv')
    $DistributionGroups | Select-Object $GroupProp | Sort-Object DisplayName | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_DistributionGroup.csv')

    $DistributionGroups | Export-MembersOnePerLine -FindInColumn MembersName | Sort-Object DisplayName |
    Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_DGMembers.csv')

    $DistributionGroups | Export-MembersOnePerLine -FindInColumn MembersSMTP | Sort-Object DisplayName |
    Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_DGMembersEmail.csv')

    # Exchange Recipients
    Write-Verbose "Retrieving Exchange Recipients"
    Get-Recipient -ResultSize unlimited | Select-Object * | Export-Clixml -Path (Join-Path -Path $Detailed -ChildPath 'ExchangeRecipients.xml')

    $Recipients = Get-365Recipient -DetailedReport

    $Recipients | Export-Csv @CSVSplat -Path (Join-Path -Path $Detailed -ChildPath 'ExchangeRecipients.csv')

    $Recipients | Where-Object { $_.RecipientTypeDetails -ne 'DiscoveryMailbox' } | Select-Object $RecipientProp | Sort-Object DisplayName |
    Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_Recipient.csv')

    $Recipients | Group-Object RecipientTypeDetails | Select-Object name, count | Sort-Object -Property count -Descending |
    Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_RecipientTypes.csv')

    $RecipientsWithEmails = $Recipients | Where-Object { $_.RecipientTypeDetails -ne 'DiscoveryMailbox' -and $_.EmailAddresses }

    Export-EmailsOnePerLine -FindInColumn EmailAddresses -RowList $RecipientsWithEmails | Sort-Object DisplayName |
    Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_RecipientEmails.csv')

    # Exchange Mailboxes
    Write-Verbose "Retrieving Exchange Mailboxes"
    Get-Mailbox -ResultSize unlimited | Select-Object * | Export-Clixml -Path (Join-Path -Path $Detailed -ChildPath 'ExchangeMailboxes.xml')
    $Mailboxes = Get-EXMailbox -DetailedReport | Where-Object { $_.RecipientTypeDetails -ne 'DiscoveryMailbox' }
    $Mailboxes | Export-Csv @CSVSplat -Path (Join-Path -Path $Detailed -ChildPath 'ExchangeMailboxes.csv')
    $Mailboxes | Select-Object $MailboxProp | Sort-Object DisplayName | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_Mailboxes.csv')

    $Mailboxes | Group-Object RecipientTypeDetails | Select-Object name, count | Sort-Object -Property count -Descending |
    Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_MailboxTypes.csv')

    Write-Verbose "Retrieving Exchange Online Resource Mailboxes and Calendar Processing"
    $ResourceMailboxes = $Mailboxes | Where-Object { $_.RecipientTypeDetails -in 'RoomMailbox', 'EquipmentMailbox' }
    Get-EXOResourceMailbox -ResourceMailbox $ResourceMailboxes | Sort-Object DisplayName |
    Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_ResourceMailboxes.csv')

    # Exchange Contacts
    Write-Verbose "Retrieving Exchange Mail Contacts"
    Get-MailContact -ResultSize unlimited | Select-Object * | Export-Clixml -Path (Join-Path -Path $Detailed -ChildPath 'ExchangeMailContacts.xml')
    Get-EXOMailContact | Select-Object $ContactProp | Sort-Object DisplayName |
    Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_MailContacts.csv')

    # Exchange Transport Rules
    Write-Verbose "Retrieving Exchange Transport Rules"
    $TransportCollection = Export-TransportRuleCollection
    Set-Content -Path (Join-Path -Path $Detailed -ChildPath 'ExchangeTransportRules.xml') -Value $TransportCollection.FileData -Encoding Byte
    [xml]$TRuleColList = Get-Content -Path (Join-Path -Path $Detailed -ChildPath 'ExchangeTransportRules.xml')
    $TransportRuleReport = Get-TransportRuleReport
    $TransportRuleReport | Export-Csv @CSVSplat -Path (Join-Path -Path $Detailed -ChildPath 'ExchangeTransportRules.csv')

    $TransportHash = Get-TransportRuleHash -TransportData $TransportRuleReport
    $TransportCsv = Convert-TransportXMLtoCSV -TRuleColList $TRuleColList -TransportHash $TransportHash
    $TransportCsv | Sort-Object Name | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_TransportRules.csv')

    # Exchange Retention Policies
    Write-Verbose "Retrieving Exchange Retention Polices, Tags and Links"
    Get-RetentionLinks | Select-Object $RetentionProp | Sort-Object PolicyName, TagType | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_RetentionPolicies.csv')

    # Accepted Domains
    Write-Verbose "Retrieving Exchange Accepted Domains"
    Get-AcceptedDomain | Select-Object $AcceptedDomainsProp | Sort-Object Name | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_AcceptedDomains.csv')

    # Remote Domains
    Write-Verbose "Retrieving Remote Domains"
    Get-RemoteDomain | Select-Object $RemoteDomainsProp | Sort-Object DomainName | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_RemoteDomains.csv')

    Write-Verbose "Retrieving Organization Config"
    (Get-OrganizationConfig).PSObject.Properties | Select-Object Name, Value | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_OrganizationConfig.csv')

    Write-Verbose "Retrieving Organization Relationship"
    Get-OrganizationRelationship | Select-Object $OrganizationRelationshipProp | Sort-Object Id | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_OrganizationRelationship.csv')



}
