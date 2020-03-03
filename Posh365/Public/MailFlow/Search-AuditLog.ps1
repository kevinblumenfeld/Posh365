Function Search-AuditLog {
    <#
    .SYNOPSIS
    Search Audit Log logs in Exchange Online by hour or partial hour start and end times
    If desired, one or more messages can be selected from the results for more detail

    .DESCRIPTION
    Search Audit Log logs in Exchange Online by hour or partial hour start and end times
    If desired, one or more messages can be selected from the results for more detail
    Just click OK once you have selected the message(s)

    Many thanks to Matt Marchese for the initial framework of this function

    .PARAMETER SenderAddress
    Senders Email Address

    .PARAMETER RecipientAddress
    Recipients Email Address

    .PARAMETER StartSearchHoursAgo
    Number of hours from today to start the search. Default is (.25) 15 minutes ago

    .PARAMETER EndSearchHoursAgo
    Number of hours from today to end the search. "Now" is the default, the number "0"

    .PARAMETER Subject
    Partial or full subject of message(s) of which are being searched

    .PARAMETER FromIP
    The IP address from which the email originated

    .PARAMETER ToIP
    The IP address to which the email was destined

    .PARAMETER Status
    The Status parameter filters the results by the delivery status of the message. Valid values for this parameter are:

    None: The message has no delivery status because it was rejected or redirected to a different recipient.
    Failed: Message delivery was attempted and it failed or the message was filtered as spam or malware, or by transport rules.
    Pending: Message delivery is underway or was deferred and is being retried.
    Delivered: The message was delivered to its destination.
    Expanded: There was no message delivery because the message was addressed to a distribution group, and the membership of the distribution was expanded.

    .EXAMPLE
    Search-AuditLog

    .EXAMPLE
    Search-AuditLog -StartSearchHoursAgo 10 -EndSearchHoursAgo 5 -Subject "arizona"

    This will find all messages with the word "arizona" somewhere in the subject, that were sent or received anywhere from 10 hours ago till 5 hours ago

    .EXAMPLE
    Search-AuditLog -StartSearchHoursAgo 10 -EndSearchHoursAgo 5 -Subject "Letter from the CEO"

    .EXAMPLE
    Search-AuditLog -SenderAddress "User@domain.com" -RecipientAddress "recipient@domain.com" -StartSearchHoursAgo 15 -FromIP "xx.xx.xx.xx"

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
        [int] $ResultSize = 100,

        [Parameter()]
        [string] $Status
    )

    $currentErrorActionPrefs = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'

    if ($StartSearchHoursAgo) {
        [DateTime]$StartSearchHoursAgo = ((Get-Date).AddHours( - $StartSearchHoursAgo))
        $StartSearchHoursAgo = $StartSearchHoursAgo.ToUniversalTime()
    }

    if ($StartSearchHoursAgo) {
        [DateTime]$EndSearchHoursAgo = ((Get-Date).AddHours( - $EndSearchHoursAgo))
        $EndSearchHoursAgo = $EndSearchHoursAgo.ToUniversalTime()
    }

    $cmdletParams = (Get-Command $PSCmdlet.MyInvocation.InvocationName).Parameters.Keys

    $params = @{ }
    $NotArray = 'StartSearchHoursAgo', 'EndSearchHoursAgo', 'Operations', 'ResultSize' , 'RecordType', 'Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'InformationAction', 'ErrorVariable', 'WarningVariable', 'InformationVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable'
    foreach ($cmdletParam in $cmdletParams) {
        if ($cmdletParam -notin $NotArray) {
            if ([string]::IsNullOrWhiteSpace((Get-Variable -Name $cmdletParam).Value) -ne $true) {
                $params.Add($cmdletParam, (Get-Variable -Name $cmdletParam).Value)
            }
        }
    }
    $params.Add('StartDate', $StartSearchHoursAgo)
    $params.Add('EndDate', $EndSearchHoursAgo)


    $counter = 1
    $continue = $false
    $ResultList = [System.Collections.Generic.List[PSObject]]::New()

    Write-Verbose "Checking audit log results on page $counter."
    try {
        if (-not $Subject) {
            Search-UnifiedAuditLog @params | ForEach-Object {
                $AuditLogResults = [PSCustomObject]@{
                    RecordType   = $_.RecordType
                    CreationDate = ($_.CreationDate).ToLocalTime()
                    UserIds      = $_.UserIds
                    Operations   = $_.Operations
                    AuditData    = $_.AuditData
                }
                $ResultList.Add($AuditLogResults)
            }
            $counter++
        }
        else {
            $AuditLog = Search-UnifiedAuditLog @params
            $AuditLogwithSubject = ""
            $AuditLogwithSubject = $AuditLog | Where-Object { $_.Subject -like "*$Subject*" }

            if ($AuditLogwithSubject) {
                $AuditLogwithSubject | ForEach-Object {
                    $AuditLogResults = [PSCustomObject]@{
                        RecordType   = $_.RecordType
                        CreationDate = ($_.CreationDate).ToLocalTime()
                        UserIds      = $_.UserIds
                        Operations   = $_.Operations
                        AuditData    = $_.AuditData
                    }
                    $ResultList.Add($AuditLogResults)
                }

            }
            if (-not $AuditLog) {
                Write-Verbose "`tNo results found on page $counter."
                $continue = $true
            }
            else {
                $counter++
                Start-Sleep -Seconds 2
            }
        }
    }
    catch {
        Write-Verbose "`tException gathering audit log data on page $counter. Trying again in 30 seconds."
        Start-Sleep -Seconds 1
    }

    if ($ResultList.count -gt 0) {
        Write-Verbose "`n$($ResultList.count) results returned."

        $DetailList = $ResultList | Out-GridView -PassThru -Title "Audit Log Results. Select one or more then click OK for detailed report."
        if ($DetailList) {
            Foreach ($Detail in $DetailList) {
                $Splat = @{
                    MessageTraceID   = $Detail.MessageTraceID
                    RecipientAddress = $Detail.RecipientAddress
                    MessageId        = $Detail.MessageId
                }
                $TraceDetail = Search-UnifiedAuditLog @Splat
                $TraceDetail | Out-GridView -Title "DATE: $($Detail.Received) STATUS: $($Detail.Status) FROM: $($Detail.SenderAddress) TO: $($Detail.RecipientAddress) TRACEID: $($Detail.MessageTraceId)"
            }
        }
    }
    else {
        Write-Verbose "`nNo Results found."
    }
    $ErrorActionPreference = $currentErrorActionPrefs
}
