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
        $SkipPermissionsReport
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
        $RecipientProperties = @(
            'RecipientTypeDetails', 'Name', 'DisplayName', 'Office', 'Alias', 'Identity', 'PrimarySmtpAddress'
            'WindowsLiveID', 'LitigationHoldEnabled', 'EmailAddresses'
        )
        $MsolUserProperties = @(
            'UserPrincipalName', 'DisplayName', 'Title', 'FirstName', 'LastName', 'StreetAddress'
            'City', 'State', 'PostalCode', 'Country', 'PhoneNumber', 'MobilePhone', 'Fax', 'Department', 'Office'
            'LastDirSyncTime', 'IsLicensed', 'ProxyAddresses'
        )
        $EXOGroupProperties = @(
            'Name', 'DisplayName', 'Alias', 'GroupType', 'Identity', 'PrimarySmtpAddress', 'RecipientTypeDetails'
            'WindowsEmailAddress', 'AcceptMessagesOnlyFromSendersOrMembers', 'ManagedBy', 'EmailAddresses', 'x500'
            'membersName', 'membersSMTP'
        )
        $EXOMailboxProperties = @(
            'Name', 'RecipientTypeDetails', 'DisplayName', 'UserPrincipalName', 'Identity', 'PrimarySmtpAddress', 'Alias'
            'ForwardingAddress', 'ForwardingSmtpAddress', 'LitigationHoldDate', 'AccountDisabled', 'DeliverToMailboxAndForward'
            'HiddenFromAddressListsEnabled', 'IsDirSynced', 'LitigationHoldEnabled', 'LitigationHoldDuration'
            'LitigationHoldOwner', 'Office', 'RetentionPolicy', 'WindowsEmailAddress', 'ArchiveName', 'AcceptMessagesOnlyFrom'
            'AcceptMessagesOnlyFromDLMembers', 'AcceptMessagesOnlyFromSendersOrMembers', 'RejectMessagesFrom'
            'RejectMessagesFromDLMembers', 'RejectMessagesFromSendersOrMembers', 'InPlaceHolds', 'x500', 'EmailAddresses'
        )
        $MSOL_Users = (Join-Path $TenantPath 'MSOL_Users.csv')
        $MSOL_Groups = (Join-Path $TenantPath 'MSOL_Groups.csv')
        $MSOL_Users_Detailed = (Join-Path $DetailedTenantPath 'MSOL_Users_Detailed.csv')

        $EXO_MailContacts = (Join-Path $TenantPath 'EXO_MailContacts.csv')
        $EXO_Recipients = (Join-Path $TenantPath 'EXO_Recipients.csv')
        $EXO_Groups = (Join-Path $TenantPath 'EXO_Groups.csv')
        $EXO_Mailboxes = (Join-Path $TenantPath 'EXO_Mailboxes.csv')
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

        $365_UnifiedGroups = (Join-Path $TenantPath '365_UnifiedGroups.csv')

        if (-not $ComplianceOnly) {
            if (-not $Filtered) {
                Write-Verbose "Gathering 365 Recipients"
                Get-365Recipient -DetailedReport | Export-Csv $EXO_Recipients_Detailed @ExportCSVSplat
                Import-Csv $EXO_Recipients_Detailed | Select-Object $RecipientProperties | Export-Csv $EXO_Recipients @ExportCSVSplat

                Write-Verbose "Gathering MsolUsers"
                Get-365MsolUser -DetailedReport | Export-Csv $MSOL_Users_Detailed @ExportCSVSplat
                Import-Csv $MSOL_Users_Detailed | Select-Object $MsolUserProperties | Export-Csv $MSOL_Users @ExportCSVSplat

                Write-Verbose "Gathering Mail Contacts"
                Get-EXOMailContact | Export-Csv $EXO_MailContacts @ExportCSVSplat

                Write-Verbose "Gathering MsolGroups"
                Get-365MsolGroup | Export-Csv $MSOL_Groups @ExportCSVSplat

                Write-Verbose "Gathering Distribution & Mail-Enabled Security Groups"
                Get-EXOGroup -DetailedReport | Export-Csv $EXO_Groups_Detailed @ExportCSVSplat
                Import-Csv $EXO_Groups_Detailed | Select-Object $EXOGroupProperties | Export-Csv $EXO_Groups @ExportCSVSplat

                Write-Verbose "Gathering Exchange Online Mailboxes"
                Get-EXOMailbox -DetailedReport | Export-Csv $EXO_Mailboxes_Detailed @ExportCSVSplat
                Import-Csv $EXO_Mailboxes_Detailed | Select-Object $EXOMailboxProperties | Export-Csv $EXO_Mailboxes @ExportCSVSplat

                Write-Verbose "Gathering Exchange Online Archive Mailboxes"
                Get-EXOMailbox -ArchivesOnly -DetailedReport | Export-Csv $EXO_ArchiveMailboxes_Detailed @ExportCSVSplat
                Import-Csv $EXO_ArchiveMailboxes_Detailed | Select-Object $EXOMailboxProperties | Export-Csv $EXO_ArchiveMailboxes @ExportCSVSplat

                Write-Verbose "Gathering Exchange Online Resource Mailboxes and Calendar Processing"
                Get-EXOResourceMailbox | Export-Csv $EXO_ResourceMailboxes @ExportCSVSplat

                if (-not $SkipLicensingReport) {
                    Write-Verbose "Gathering Office 365 Licenses"
                    Get-CloudLicense -Path $TenantPath
                }
                if (-not $SkipPermissionsReport) {
                    Write-Verbose "Gathering Mailbox Delegate Permissions"
                    Get-EXOMailboxPerms -Path $TenantPath

                    Write-Verbose "Gathering Distribution Group Delegate Permissions"
                    Get-EXODGPerms -Path $TenantPath
                }
            }
            else {
                Write-Verbose "Gathering 365 Recipients - filtered"
                '{UserPrincipalName -like "*contoso.com" -or
            emailaddresses -like "*contoso.com" -or
            ExternalEmailAddress -like "*contoso.com" -or
            PrimarySmtpAddress -like "*contoso.com"}' | Get-365Recipient -DetailedReport | Export-Csv $EXO_Recipients_Detailed @ExportCSVSplat
                Import-Csv $EXO_Recipients_Detailed | Select-Object $RecipientProperties | Export-Csv $EXO_Recipients @ExportCSVSplat

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
            Write-Verbose "Gathering Retention Polices and linked Retention Policy Tags"
            Get-RetentionLinks | Export-Csv $EXO_RetentionPolicies @ExportCSVSplat

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
            Get-RemoteDomain | Export-Csv $EXO_RemoteDomains @ExportCSVSplat

            Write-Verbose "Gathering Organization Config"
            Get-OrganizationConfig | Export-Csv $EXO_OrganizationConfig @ExportCSVSplat

            Write-Verbose "Gathering Organization Relationship"
            Get-OrganizationRelationship | Export-Csv $EXO_OrganizationRelationship @ExportCSVSplat
        }
        else {
            Write-Verbose "Gathering DLP Compliance Policies"
            Get-DlpCompliancePolicy -DistributionDetail | Export-Csv $Compliance_DLPPolicies @ExportCSVSplat

            Write-Verbose "Gathering Compliance Retention Policies"
            Get-RetentionCompliancePolicy -DistributionDetail | Export-Csv $Compliance_RetentionPolicies @ExportCSVSplat

            Write-Verbose "Gathering Compliance Alert Policies"
            Get-ProtectionAlert | Export-Csv $Compliance_AlertPolicies @ExportCSVSplat
        }
    }
}
