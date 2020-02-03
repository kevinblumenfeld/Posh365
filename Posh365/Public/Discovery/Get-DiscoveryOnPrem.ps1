function Get-DiscoveryOnPrem {
    <#
    .SYNOPSIS
    On-Premises Active Directory and Exchange Discovery

    .EXAMPLE
    Get-DiscoveryOnPrem -Verbose

    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $SkipDetailedExcel
    )

    try {
        Import-Module ActiveDirectory -ErrorAction Stop -Verbose:$false
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
            Connect-Exchange -Server $ServerName -Verbose:$false
        }
    } until ($Answer -eq 'Y' -or $Answer -eq 'N')

    Write-Verbose "Setting Exchange's ADServerSettings to ViewEntireForest"
    Set-ADServerSettings -ViewEntireForest:$True

    $RecipientProp = @(
        'DisplayName', 'RecipientTypeDetails', 'OrganizationalUnit', 'Office', 'Alias', 'Identity', 'PrimarySmtpAddress'
        'WindowsLiveID', 'LitigationHoldEnabled', 'Name', 'EmailAddresses', 'Guid'
    )
    $GroupProp = @(
        'DisplayName', 'OrganizationalUnit', 'Alias', 'GroupType', 'IsDirSynced', 'PrimarySmtpAddress', 'RecipientTypeDetails'
        'WindowsEmailAddress', 'AcceptMessagesOnlyFromSendersOrMembers', 'RequireSenderAuthenticationEnabled'
        'ManagedBy', 'EmailAddresses', 'x500', 'Name', 'membersName', 'membersSMTP', 'Identity', 'Guid'
        'LegacyExchangeDN'
    )
    $MailboxProp = @(
        'DisplayName', 'OrganizationalUnit', 'Office', 'RecipientTypeDetails', 'EmailAddressPolicyEnabled', 'MailboxGB'
        'ArchiveGB', 'DeletedGB', 'TotalGB', 'LastLogonTime', 'ItemCount', 'ArchiveState', 'ArchiveStatus'
        'ArchiveName', 'MaxReceiveSize', 'MaxSendSize', 'MapiHttpEnabled', 'ActiveSyncEnabled', 'OWAEnabled', 'ECPEnabled'
        'PopEnabled', 'ImapEnabled', 'MAPIEnabled', 'EwsEnabled', 'RecipientLimits', 'AcceptMessagesOnlyFrom'
        'AcceptMessagesOnlyFromDLMembers', 'ForwardingAddress', 'ForwardingSmtpAddress', 'DeliverToMailboxAndForward'
        'UserPrincipalName', 'PrimarySmtpAddress', 'Identity', 'AddressBookPolicy', 'RetentionPolicy', 'LitigationHoldEnabled'
        'LitigationHoldDuration', 'LitigationHoldOwner', 'InPlaceHolds', 'Guid', 'x500', 'EmailAddresses'
    )
    $UPNMatchProp = @(
        'DisplayName', 'RecipientTypeDetails', 'OrganizationalUnit', 'UserPrincipalName', 'PrimarySmtpAddress', 'Guid'
    )
    $ContactProp = @(
        'DisplayName', 'OrganizationalUnit', 'PrimarySmtpAddress', 'WindowsEmailAddress', 'ExternalEmailAddress', 'EmailAddresses'
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
        'MailTipTranslations', 'PoliciesExcluded', 'PoliciesIncluded', 'DistinguishedName'
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
        'Guid', 'Id', 'IsValid', 'ObjectState', 'DistinguishedName', 'ByteEncoderTypeFor7BitCharsets'
        'CharacterSet', 'NonMimeCharacterSet'
    )
    $OrganizationRelationshipProp = @(
        'Id', 'DomainNames', 'FreeBusyAccessEnabled', 'FreeBusyAccessLevel', 'FreeBusyAccessScope'
        'MailboxMoveEnabled', 'MailboxMoveCapability', 'OAuthApplicationId', 'DeliveryReportEnabled'
        'MailTipsAccessEnabled', 'MailTipsAccessLevel', 'MailTipsAccessScope', 'PhotosEnabled'
        'TargetApplicationUri', 'TargetSharingEpr', 'TargetOwaURL', 'TargetAutodiscoverEpr'
        'OrganizationContact', 'Enabled', 'ArchiveAccessEnabled', 'AdminDisplayName', 'ExchangeVersion'
        'Name', 'DistinguishedName', 'Identity', 'ObjectCategory', 'WhenChanged', 'WhenCreated'
        'WhenChangedUTC', 'WhenCreatedUTC', 'Guid', 'IsValid', 'ObjectState'
    )
    $ActiveSyncRule = @(
        'Name', 'AccessLevel', 'QueryString', 'WhenCreated', 'WhenChanged', 'Guid'
    )
    $ADUsersProp = @(
        'DisplayName', 'OU(CN)', 'Office', 'Department', 'Company', 'Enabled'
        'InheritanceBroken', 'UserPrincipalName', 'PrimarySmtpAddress', 'Description'
    )

    $Discovery = Join-Path ([Environment]::GetFolderPath("Desktop")) -ChildPath 'Discovery'
    $Detailed = Join-Path $Discovery -ChildPath 'Detailed'
    $CSV = Join-Path $Discovery -ChildPath 'CSV'
    $null = New-Item -ItemType Directory -Path $Discovery -ErrorAction SilentlyContinue
    $null = New-Item -ItemType Directory -Path $Detailed -ErrorAction SilentlyContinue
    $null = New-Item -ItemType Directory -Path $CSV -ErrorAction SilentlyContinue

    $CsvSplat = @{
        NoTypeInformation = $true
        Encoding          = 'UTF8'
    }


    ##################
    #### EXCHANGE ####
    ##################

    # Exchange Mailboxes
    Write-Verbose "Retrieving Exchange Mailboxes"
    $Mailboxes = Get-ExMailbox -DetailedReport | Where-Object { $_.RecipientTypeDetails -ne 'DiscoveryMailbox' }
    $Mailboxes | Export-Csv @CSVSplat -Path (Join-Path -Path $Detailed -ChildPath 'ExchangeMailboxes.csv')
    $Mailboxes | Select-Object $MailboxProp | Sort-Object DisplayName | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_Mailboxes.csv')

    Remove-Item -Path (Join-Path -Path $CSV -ChildPath 'Ex_MessageLimits.csv') -Force -ErrorAction SilentlyContinue
    $Mailboxes | Group-Object MaxReceiveSize, RecipientTypeDetails -NoElement | Select-Object @(
        @{
            Name       = 'Type'
            Expression = { 'MaxReceiveSize' }
        }
        'count'
        @{
            Name       = 'Max'
            Expression = { ($_.Name.split(',')[0]).split('(')[0] }
        }
        @{
            Name       = 'Name'
            Expression = { [regex]::Matches($($_.Name), "[^,]*$").value[0] }
        }
    ) | Sort-Object count -Descending | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_MessageLimits.csv') -Append

    $Mailboxes | Group-Object { ($_.prohibitSendReceiveQuota.split('(')[0]).padleft(2) } -NoElement | Sort-Object Count -Descending | Select-Object @(
        @{
            name       = 'MailboxCount'
            expression = 'Count'
        }
        @{
            name       = 'ProhibitSendRecieve'
            expression = 'Name'
        }
    ) | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_MailboxQuotas.csv')

    $Mailboxes | Group-Object MaxSendSize, RecipientTypeDetails -NoElement | Select-Object @(
        @{
            Name       = 'Type'
            Expression = { 'MaxSendSize' }
        }
        'count'
        @{
            Name       = 'Max'
            Expression = { ($_.Name.split(',')[0]).split('(')[0] }
        }
        @{
            Name       = 'Name'
            Expression = { [regex]::Matches($($_.Name), "[^,]*$").value[0] }
        }
    ) | Sort-Object count -Descending | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_MessageLimits.csv') -Append


    Get-TransportRule | Where-Object { $_.MessageSizeOver -or $_.AttachmentSizeOver } | Select-Object @(
        @{
            Name       = 'Type'
            Expression = { 'TransportRule' }
        }
        'count'
        @{
            Name       = 'Max'
            Expression = { if ($_.MessageSizeOver -and $_.AttachmentSizeOver) {
                    '{0},{1}' -f ($_.MessageSizeOver).split('(')[0].trim(), ($_.AttachmentSizeOver).split('(')[0].trim()
                }
                elseif ($_.MessageSizeOver) { '{0}' -f ($_.MessageSizeOver).split('(')[0].trim() }
                else { '{0}' -f ($_.AttachmentSizeOver).split('(')[0].trim() }
            }
        }
        @{
            Name       = 'Name'
            Expression = { $_.Name }
        }
    ) | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_MessageLimits.csv') -Append

    Get-TransportConfig | Select-Object @(
        @{
            Name       = 'Type'
            Expression = { 'TransportConfig' }
        }
        'count'
        @{
            Name       = 'Max'
            Expression = { '{0},{1}' -f ($_.Maxreceivesize).split('(')[0].trim(), ($_.MaxSendSize).split('(')[0].trim() }
        }
        @{
            Name       = 'Name'
            Expression = { 'TransportConfig' }
        }
    ) | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_MessageLimits.csv') -Append


    # Exchange Mailboxes Types
    Write-Verbose "Retrieving Exchange Mailbox Types"
    $Mailboxes | Group-Object RecipientTypeDetails | Select-Object name, count | Sort-Object -Property count -Descending |
    Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_MailboxTypes.csv')

    Get-Mailbox -ResultSize unlimited | Select-Object * | Export-Clixml -Path (Join-Path -Path $Detailed -ChildPath 'ExchangeMailboxes.xml')

    # Exchange Mailbox PrimarySmtpAddress Domains
    Write-Verbose "Retrieving Exchange Mailbox PrimarySmtpAddress Domains"
    $PrimaryDomains = $Mailboxes | Select-Object @(
        @{
            Name       = 'PrimaryDomains'
            Expression = { $_.PrimarySMTPAddress.split('@')[1] }
        }
    ) | Group-Object -Property 'PrimaryDomains' | Select-Object Count, Name | Sort-Object count -Descending
    $PrimaryDomains | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_PrimaryDomains.csv')

    # DNS Security Records
    Write-Verbose "Retrieving PrimarySmtpAddress Domains DNS Mail Security Records"
    foreach ($Primary in $PrimaryDomains) {
        (Get-EmailSecurityRecords -EmailDomain $Primary.Name).PSObject.Properties | Select-Object Name, Value | Export-Csv @CSVSplat -Path ((Join-Path -Path $CSV -ChildPath 'Dns_{0}.csv') -f $Primary.Name)
    }

    # Exchange Retention Policy Summary
    Write-Verbose "Retrieving Exchange Retention Policy Summary"
    $Mailboxes | Group-Object RetentionPolicy | Select-Object name, count | Sort-Object -Property count -Descending |
    Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_RetentionPolicySummary.csv')

    # Exchange Test UPN match PrimarySMTPAddress
    Write-Verbose "Retrieving Exchange Mailboxes where UPN -ne PrimarySmtpAddress"
    $Mailboxes.where{ $_.UserPrincipalName -ne $_.PrimarySmtpAddress } | Select-Object $UPNMatchProp | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_UpnNotMatch.csv')

    # Exchange Server
    $PP = $global:ProgressPreference
    $global:ProgressPreference = 'SilentlyContinue'
    Write-Verbose "Retrieving Exchange Servers"
    $ExServerList = Get-ExchangeServer
    $ExServerObject = foreach ($ExServer in $ExServerList) {
        $ExPing = Test-NetConnection -ComputerName $ExServer
        [PSCustomObject]@{
            Name                      = $ExServer.Name
            ServerRole                = $ExServer.ServerRole
            Site                      = [regex]::Matches("$($ExServer.Site)", "[^/]*$").value[0]
            IP                        = $ExPing.RemoteAddress
            PingSucceeded             = $ExPing.PingSucceeded
            IsHubTransportServer      = $ExServer.IsHubTransportServer
            IsClientAccessServer      = $ExServer.IsClientAccessServer
            IsMailboxServer           = $ExServer.IsMailboxServer
            IsUnifiedMessagingServer  = $ExServer.IsUnifiedMessagingServer
            IsFrontendTransportServer = $ExServer.IsFrontendTransportServer
            AdminDisplayVersion       = $ExServer.AdminDisplayVersion
        }
    }
    $ExServerObject | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_Servers.csv')
    $Global:ProgressPreference = $PP

    # Exchange Receive Connectors
    Write-Verbose "Retrieving Exchange Receive Connectors"
    $ReceiveConnectors = Get-ExchangeReceiveConnector | Sort-Object Identity
    $ReceiveConnectors | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_ReceiveConnectors.csv')

    $ReceiveConnectors | Select-Object @(
        @{
            Name       = 'Type'
            Expression = { 'ReceiveConnector' }
        }
        'count'
        @{
            Name       = 'Max'
            Expression = { ($_.MaxMessageSize).split('(')[0].trim() }
        }
        @{
            Name       = 'Name'
            Expression = { $_.Identity }
        }
    ) | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_MessageLimits.csv') -Append


    # Exchange Receive Connector IPs
    Write-Verbose "Retrieving Exchange Receive Connector IPs"
    $ReceiveIPs = foreach ($RecCon in $ReceiveConnectors) {
        $RecCon.RemoteIPRanges -split [regex]::Escape('|') | ForEach-Object {
            [PSCustomObject]@{
                IPRange  = $_
                Port     = [regex]::Matches($RecCon.Bindings, "[^:]*$").value[0]
                Identity = $RecCon.Identity
                Enabled  = $RecCon.Enabled
            }
        }
    }
    $ReceiveIPs | Sort-Object IPRange, Identity -Descending | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_ReceiveIPs.csv')

    # Exchange Send Connectors
    Write-Verbose "Retrieving Exchange Send Connectors"
    $SendConnectors = Get-ExchangeSendConnector
    $SendConnectors | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_SendConnectors.csv')
    $SendConnectors | Select-Object @(
        @{
            Name       = 'Type'
            Expression = { 'SendConnector' }
        }
        'count'
        @{
            Name       = 'Max'
            Expression = { ($_.MaxMessageSize).split('(')[0].trim() }
        }
        @{
            Name       = 'Name'
            Expression = { $_.Name }
        }
    ) | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_MessageLimits.csv') -Append


    # Exchange Email Address Policies
    Write-Verbose "Retrieving Exchange Email Address Policies"
    Get-ExEmailAddressPolicy | Sort-Object Priority | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_EmailAddressPolicy.csv')

    # Exchange Address Lists
    Write-Verbose "Retrieving Exchange Address Lists"
    Get-AddressList | Get-ExchangeAddressList | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_AddressLists.csv')

    Write-Verbose "Retrieving Exchange Global Address Lists"
    Get-GlobalAddressList | Get-ExchangeGlobalAddressList | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_GlobalAddressLists.csv')

    Write-Verbose "Retrieving Exchange Offline Address Books"
    Get-OfflineAddressBook | Get-ExchangeOfflineAddressBook | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_OfflineAddressBook.csv')

    Write-Verbose "Retrieving Exchange Address Book Policies"
    Get-AddressBookPolicy | Get-ExchangeAddressBookPolicy | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_AddressBookPolicies.csv')

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

    Write-Verbose "Retrieving Exchange Recipient PrimarySmtpAddress Domains"
    $PrimaryRecipientDomains = $Recipients | Where-Object { $_.RecipientTypeDetails -ne 'DiscoveryMailbox' -and $_.RecipientTypeDetails -ne 'MailContact' } | Select-Object @(
        @{
            Name       = 'PrimaryDomains'
            Expression = { $_.PrimarySMTPAddress.split('@')[1] }
        }
    ) | Group-Object -Property 'PrimaryDomains' | Select-Object Count, Name | Sort-Object count -Descending
    $PrimaryRecipientDomains | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_PrimaryRecipientDomains.csv')

    $Recipients | Group-Object RecipientTypeDetails | Select-Object name, count | Sort-Object -Property count -Descending |
    Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_RecipientTypes.csv')

    $RecipientsWithEmails = $Recipients | Where-Object { $_.RecipientTypeDetails -ne 'DiscoveryMailbox' -and $_.EmailAddresses }

    $RecOneEmailPerLine = Export-EmailsOnePerLine -FindInColumn EmailAddresses -RowList $RecipientsWithEmails | Sort-Object DisplayName
    $RecOneEmailPerLine | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_RecipientEmails.csv')

    # Exchange Recipient Domains and OUs
    Write-Verbose "Retrieving Exchange Recipient Domains and OUs"
    $RecDomain = $RecOneEmailPerLine.where( { $_.Domain }) | Group-Object -Property Domain, RecipientTypeDetails -NoElement | Select-Object count, name
    $RecDomain | Sort-Object count -Descending | Select-Object @(
        'Count'
        @{
            Name       = 'Domain'
            Expression = { $_.Name.split(',')[0] }
        }
        @{
            Name       = 'RecipientType'
            Expression = { $_.Name.split(',')[1] }
        }
    ) | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_RecipientDomains.csv')

    $RecOU = $Recipients | Group-Object -Property OrganizationalUnit, RecipientTypeDetails -NoElement | Select-Object count, name

    $RecOU | Sort-Object count -Descending | Select-Object @(
        'Count'
        @{
            Name       = 'OrganizationalUnit'
            Expression = { $_.Name.split(',')[0] }
        }
        @{
            Name       = 'RecipientType'
            Expression = { $_.Name.split(',')[1] }
        }
    ) | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_RecipientOUs.csv')

    Write-Verbose "Retrieving Exchange Online Resource Mailboxes and Calendar Processing"
    $ResourceMailboxes = $Mailboxes | Where-Object { $_.RecipientTypeDetails -in 'RoomMailbox', 'EquipmentMailbox' }
    Get-EXOResourceMailbox -ResourceMailbox $ResourceMailboxes | Sort-Object DisplayName |
    Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_ResourceMailboxes.csv')

    # Exchange Contacts
    Write-Verbose "Retrieving Exchange Mail Contacts"
    Get-MailContact -ResultSize unlimited | Select-Object * | Export-Clixml -Path (Join-Path -Path $Detailed -ChildPath 'ExchangeMailContacts.xml')
    Get-EXOMailContact | Select-Object $ContactProp | Sort-Object DisplayName |
    Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_MailContacts.csv')

    # Exchange DLP Policies
    Write-Verbose "Retrieving Exchange DLP Policies"
    Get-DLPPolicy -ErrorAction SilentlyContinue | Select-Object @(
        'Name'
        'State'
        'Mode'
        'Description'
        'PublisherName'
        @{
            Name       = 'Keywords'
            Expression = { @($_.Keywords) -ne '' -join '|' }
        }
        'ContentVersion'
        'WhenChanged'
        'Identity'
        'Guid'
        'ExchangeVersion'
        'MaximumSupportedExchangeObjectVersion'
    ) | Sort-Object Name | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_DataLossProtection.csv')

    # Exchange Transport Rules
    Write-Verbose "Retrieving Exchange Transport Rules"
    $TransportRuleReport = Get-TransportRuleReport
    if ($TransportRuleReport) {
        $TransportCollection = Export-TransportRuleCollection
        Set-Content -Path (Join-Path -Path $Detailed -ChildPath 'ExchangeTransportRules.xml') -Value $TransportCollection.FileData -Encoding Byte
        [xml]$TRuleColList = Get-Content -Path (Join-Path -Path $Detailed -ChildPath 'ExchangeTransportRules.xml')
        $TransportRuleReport | Export-Csv @CSVSplat -Path (Join-Path -Path $Detailed -ChildPath 'ExchangeTransportRules.csv')

        $TransportHash = Get-TransportRuleHash -TransportData $TransportRuleReport
        $TransportCsv = Convert-TransportXMLtoCSV -TRuleColList $TRuleColList -TransportHash $TransportHash
        $TransportCsv | Sort-Object Name | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_TransportRules.csv')
    }

    # Exchange Retention Policies
    Write-Verbose "Retrieving Exchange Retention Polices, Tags and Links"
    Get-RetentionLinks | Select-Object $RetentionProp | Sort-Object PolicyName, TagType | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_RetentionPolicies.csv')

    # Exchange Accepted Domains
    Write-Verbose "Retrieving Exchange Accepted Domains"
    Get-AcceptedDomain | Select-Object $AcceptedDomainsProp | Sort-Object Name | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_AcceptedDomains.csv')

    # Exchange Remote Domains
    Write-Verbose "Retrieving Exchange Remote Domains"
    Get-RemoteDomain | Select-Object $RemoteDomainsProp | Sort-Object DomainName | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_RemoteDomains.csv')

    # Exchange Organization Config
    Write-Verbose "Retrieving Exchange Organization Config"
    (Get-OrganizationConfig).PSObject.Properties | Select-Object Name, Value | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_OrganizationConfig.csv')

    # Exchange Organization Relationship
    Write-Verbose "Retrieving Exchange Organization Relationship"
    Get-OrganizationRelationship | Select-Object $OrganizationRelationshipProp | Sort-Object Id | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_OrganizationRelationship.csv')

    # Exchange ActiveSync Device Access Rules
    Write-Verbose "Retrieving Exchange ActiveSync Device Access Rules"
    Get-ActiveSyncDeviceAccessRule | Select-Object $ActiveSyncRule | Sort-Object Name | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_ActiveSyncRules.csv')

    # Exchange Journal Rule
    Write-Verbose "Retrieving Exchange Journal Rule"
    @(
        (Get-JournalRule).PSObject.Properties
        (Get-TransportConfig).PSObject.Properties.where( { $_.Name -eq 'JournalingReportNdrTo' })
    ) | Select-Object -Property @(
        @{
            Name       = 'Property'
            Expression = 'Name'
        }
        'Value'
    ) | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_JournalRule.csv')

    # Exchange Mailboxes Email Address Policy is not enabled
    Write-Verbose "Retrieving Exchange Mailboxes EmailAddressPolicyEnabled is False"
    $Mailboxes.where( { -not $_.EmailAddressPolicyEnabled }) | Select-Object @(
        'DisplayName'
        'PrimarySmtpAddress'
        'UserPrincipalName'
        'OrganizationalUnit'
    ) | Sort-Object DisplayName | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_EmailAddressPolicyDisabled.csv')

    # Exchange Public Folders
    Write-Verbose "Retrieving Exchange Public Folders"
    $EA = $global:ErrorActionPreference
    $global:ErrorActionPreference = 'Stop'
    try {
        Get-EXPublicFolder | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_PublicFolders.csv')
        Get-EXPublicFolderRights | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_PublicFoldersRights.csv')
    }
    catch {
        Write-Host "$($_.Exception.Message)" -ForegroundColor DarkCyan
    }

    $global:ErrorActionPreference = $EA

    ##########################
    #### ACTIVE DIRECTORY ####
    ##########################

    # AD User
    Write-Verbose "Retrieving Active Directory Users"
    Get-ADUser -Filter * -Properties * | Select-Object * | Export-Clixml -Path (Join-Path -Path $Detailed -ChildPath 'ActiveDirectoryUsers.xml')
    $ADUsers = Get-ActiveDirectoryUser -DetailedReport
    $ProxyHash = Get-ProxyHash -ADUserList $ADUsers
    $ADUsers | Export-Csv @CSVSplat -Path (Join-Path -Path $Detailed -ChildPath 'ActiveDirectoryUsers.csv')
    $ADUsers | Select-Object $ADUsersProp | Sort-Object 'OU(CN)', 'DisplayName' | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ad_ADUsers.csv')


    Write-Verbose "Retrieving Outlook CAS Logs"
    $OutlookData = Get-OutlookVersions
    $OutlookData | Select-Object -Unique @(
        'client-software', 'client-software-version', 'client-mode'
        @{
            Name       = 'client-name'
            Expression = { ($_."client-name") }
        }
        @{
            Name       = 'DisplayName'
            Expression = { $ProxyHash['x500:' + ($_."client-name")]['DisplayName'] }
        }
    ) | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_OutlookTypes.csv')
    $OutlookData | Group-Object -Property "client-software-version" | Select-Object @(
        @{
            Name       = 'Version'
            Expression = { $_.Name }
        }
        'Count'
    ) | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_OutlookCount.csv')

    # AD Replication
    Write-Verbose "Retrieving Active Directory Replication"
    Get-ADReplication | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ad_Replication.csv')

    # Create Excel Workbook
    Write-Verbose "Creating Excel Workbook"
    $ExcelSplat = @{
        TableStyle              = 'Medium2'
        FreezeTopRowFirstColumn = $true
        AutoSize                = $true
        BoldTopRow              = $false
        ClearSheet              = $true
        ErrorAction             = 'SilentlyContinue'
    }
    Get-ChildItem -Path $CSV -Filter "*.csv" | Sort-Object BaseName |
    ForEach-Object { Import-Csv $_.fullname | Export-Excel @ExcelSplat -Path (Join-Path $Discovery 'Discovery.xlsx') -WorksheetName $_.basename }
    if (-not $SkipDetailedExcel) {
        Get-ChildItem -Path $Detailed -Filter "*.csv" | Sort-Object BaseName |
        ForEach-Object { Import-Csv $_.fullname | Export-Excel @ExcelSplat -Path (Join-Path $Detailed 'Detailed.xlsx') -WorksheetName $_.basename }

    }

    # Complete
    Write-Verbose "Script Complete"
    Write-Verbose "Results can be found on the Desktop in a folder named, Discovery"
}

