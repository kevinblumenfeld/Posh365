function Search-AuditLog {
    <#
    .SYNOPSIS
    Search the unified admin audit log

    .DESCRIPTION
    Search the unified admin audit log

    .PARAMETER StartSearchHoursAgo
    Type the number of hours in the past to "Start" your search
    Using .01 is even acceptable

    .PARAMETER EndSearchHoursAgo
    Type the number of hours in the past to "End" your search
    Default is 0 - which is the present (now)

    .PARAMETER RecordType
    The RecordType parameter filters the log entries by record type. Valid values are:

        AeD
        AirInvestigation
        ApplicationAudit
        AzureActiveDirectory
        AzureActiveDirectoryAccountLogon
        AzureActiveDirectoryStsLogon
        Campaign
        ComplianceDLPExchange
        ComplianceDLPSharePoint
        ComplianceDLPSharePointClassification
        ComplianceSupervisionExchange
        CRM
        CustomerKeyServiceEncryption
        DataCenterSecurityCmdlet
        DataGovernance
        DataInsightsRestApiAudit
        Discovery
        DLPEndpoint
        ExchangeAdmin
        ExchangeAggregatedOperation
        ExchangeItem
        ExchangeItemAggregated
        ExchangeItemGroup
        HRSignal
        HygieneEvent
        InformationBarrierPolicyApplication
        InformationWorkerProtection
        Kaizala
        LabelExplorer
        MailSubmission
        MicrosoftFlow
        MicrosoftForms
        MicrosoftStream
        MicrosoftTeams
        MicrosoftTeamsAddOns
        MicrosoftTeamsAdmin
        MicrosoftTeamsAnalytics
        MicrosoftTeamsDevice
        MicrosoftTeamsSettingsOperation
        MipAutoLabelSharePointItem
        MipAutoLabelSharePointPolicyLocation
        MIPLabel
        OfficeNative
        OneDrive
        PowerAppsApp
        PowerAppsPlan
        PowerBIAudit
        Project
        Quarantine
        SecurityComplianceAlerts
        SecurityComplianceCenterEOPCmdlet
        SecurityComplianceInsights
        SharePoint
        SharePointCommentOperation
        SharePointContentTypeOperation
        SharePointFieldOperation
        SharePointFileOperation
        SharePointListItemOperation
        SharePointListOperation
        SharePointSharingOperation
        SkypeForBusinessCmdlets
        SkypeForBusinessPSTNUsage
        SkypeForBusinessUsersBlocked
        Sway
        SyntheticProbe
        TeamsHealthcare
        ThreatFinder
        ThreatIntelligence
        ThreatIntelligenceAtpContent
        ThreatIntelligenceUrl
        WorkplaceAnalytics
        Yammer

    .PARAMETER Operations
     The Operations parameter filters the log entries by operation. There are others that can be found here:
     https://docs.microsoft.com/en-us/microsoft-365/compliance/search-the-audit-log-in-security-and-compliance?view=o365-worldwide#audited-activities

     Let me know if you would like any others added besides this list

        Add user
        AddFolderPermissions
        AddMailboxPermissions
        ApplyRecordLabel
        Change user license
        Change user password
        ClientViewSignaled
        ComplianceRecordDelete
        ComplianceSettingChanged
        Copy
        Create
        Delete user
        DocumentSensitivityMismatchDetected
        FileAccessed
        FileAccessedExtended
        FileCheckedIn
        FileCheckedOut
        FileCheckOutDiscarded
        FileCopied
        FileDeleted
        FileDeletedFirstStageRecycleBin
        FileDeletedSecondStageRecycleBin
        FileDownloaded
        FileMalwareDetected
        FileModified
        FileModifiedExtended
        FileMoved
        FilePreviewed
        FileRenamed
        FileRestored
        FileUploaded
        FileVersionRecycled
        FileVersionsAllMinorsRecycled
        FileVersionsAllRecycled
        HardDelete
        LockRecord
        MailboxLogin
        MailItemsAccessed
        Move
        MoveToDeletedItems
        New-InboxRule
        PagePrefetched
        PageViewed
        PageViewedExtended
        RemoveFolderPermissions
        Remove-MailboxPermission
        Reset user password
        SearchQueryPerformed
        SendAs
        SendOnBehalf
        Set force change user password
        Set license properties
        Set-InboxRule
        SoftDelete
        UnlockRecord
        Update
        Update user
        UpdateCalendarDelegation
        UpdateFolderPermissions
        UpdateInboxRules

    .PARAMETER ResultSize
    Default is 5000 with built in paging.

    .EXAMPLE
    Search-AuditLog -StartSearchHoursAgo 24 -Operations AddFolderPermissions

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Double] $StartSearchHoursAgo = ".25",

        [Parameter()]
        [Double] $EndSearchHoursAgo = "0",

        [Parameter()]
        [ValidateSet(
            'AeD', 'AirInvestigation', 'ApplicationAudit', 'AzureActiveDirectory',
            'AzureActiveDirectoryAccountLogon', 'AzureActiveDirectoryStsLogon',
            'Campaign', 'ComplianceDLPExchange', 'ComplianceDLPSharePoint',
            'ComplianceDLPSharePointClassification', 'ComplianceSupervisionExchange',
            'CRM', 'CustomerKeyServiceEncryption', 'DataCenterSecurityCmdlet', 'DataGovernance',
            'DataInsightsRestApiAudit', 'Discovery', 'DLPEndpoint', 'ExchangeAdmin',
            'ExchangeAggregatedOperation', 'ExchangeItem', 'ExchangeItemAggregated',
            'ExchangeItemGroup', 'HRSignal', 'HygieneEvent',
            'InformationBarrierPolicyApplication', 'InformationWorkerProtection',
            'Kaizala', 'LabelExplorer', 'MailSubmission', 'MicrosoftFlow',
            'MicrosoftForms', 'MicrosoftStream', 'MicrosoftTeams', 'MicrosoftTeamsAddOns',
            'MicrosoftTeamsAdmin', 'MicrosoftTeamsAnalytics', 'MicrosoftTeamsDevice',
            'MicrosoftTeamsSettingsOperation', 'MipAutoLabelSharePointItem',
            'MipAutoLabelSharePointPolicyLocation', 'MIPLabel', 'OfficeNative', 'OneDrive',
            'PowerAppsApp', 'PowerAppsPlan', 'PowerBIAudit', 'Project', 'Quarantine',
            'SecurityComplianceAlerts', 'SecurityComplianceCenterEOPCmdlet',
            'SecurityComplianceInsights', 'SharePoint', 'SharePointCommentOperation',
            'SharePointContentTypeOperation', 'SharePointFieldOperation', 'SharePointFileOperation',
            'SharePointListItemOperation', 'SharePointListOperation', 'SharePointSharingOperation',
            'SkypeForBusinessCmdlets', 'SkypeForBusinessPSTNUsage', 'SkypeForBusinessUsersBlocked',
            'Sway', 'SyntheticProbe', 'TeamsHealthcare', 'ThreatFinder', 'ThreatIntelligence',
            'ThreatIntelligenceAtpContent', 'ThreatIntelligenceUrl', 'WorkplaceAnalytics', 'Yammer'
        )]
        [string[]]
        $RecordType,

        [Parameter()]
        [ValidateSet(
            'ClientViewSignaled', 'ComplianceRecordDelete', 'ComplianceSettingChanged',
            'DocumentSensitivityMismatchDetected', 'FileAccessed', 'FileAccessedExtended',
            'FileCheckedIn', 'FileCheckedOut', 'FileCheckOutDiscarded', 'FileCopied',
            'FileDeleted', 'FileDeletedFirstStageRecycleBin', 'FileDeletedSecondStageRecycleBin',
            'FileDownloaded', 'FileMalwareDetected', 'FileModified', 'FileModifiedExtended',
            'FileMoved', 'FilePreviewed', 'FileRenamed', 'FileRestored', 'FileUploaded',
            'FileVersionRecycled', 'FileVersionsAllMinorsRecycled', 'FileVersionsAllRecycled',
            'LockRecord', 'PagePrefetched', 'PageViewed', 'PageViewedExtended',
            'SearchQueryPerformed', 'UnlockRecord', 'AddFolderPermissions',
            'AddMailboxPermissions', 'ApplyRecordLabel', 'Copy', 'Create', 'HardDelete',
            'MailboxLogin', 'MailItemsAccessed', 'Move', 'MoveToDeletedItems', 'New-InboxRule',
            'RemoveFolderPermissions', 'Remove-MailboxPermission', 'SendAs', 'SendOnBehalf',
            'Set-InboxRule', 'SoftDelete', 'Update', 'UpdateCalendarDelegation',
            'UpdateFolderPermissions', 'UpdateInboxRules', 'Add user', 'Change user license',
            'Change user password', 'Delete user', 'Reset user password',
            'Set force change user password', 'Set license properties', 'Update user'
        )]
        [string[]]
        $Operations,

        [Parameter()]
        [int]
        $ResultSize = 5000
    )

    $SessionId = [DateTime]::Now.ToLocalTime()

    if ($StartSearchHoursAgo) {
        [DateTime]$StartSearchHoursAgo = ((Get-Date).AddHours( - $StartSearchHoursAgo))
        $StartSearchHoursAgo = $StartSearchHoursAgo.ToUniversalTime()
    }

    if ($StartSearchHoursAgo) {
        [DateTime]$EndSearchHoursAgo = ((Get-Date).AddHours( - $EndSearchHoursAgo))
        $EndSearchHoursAgo = $EndSearchHoursAgo.ToUniversalTime()
    }

    $params = @{
        'StartDate'      = $StartSearchHoursAgo
        'EndDate'        = $EndSearchHoursAgo
        'SessionCommand' = 'returnlargeset'
        'SessionId'      = $SessionId
        'ResultSize'     = $ResultSize
    }

    if ($RecordType) { $params.Add('RecordType', $RecordType) }
    if ($Operations) { $params.Add('Operations', $Operations) }

    try {
        Invoke-SearchAuditLog @params | Out-GridView
    }
    catch {
        if ($_.Exception.Message -match 'Cannot index into a null array') {
            Write-Warning "No data found"
        }
        else { Write-Warning $_.Exception.Message }
    }
}
