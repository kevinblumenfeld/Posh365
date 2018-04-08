function Get-EXOResourceMailbox { 
    <#
    .SYNOPSIS
    Export Office 365 Resource Mailboxes and Calendar Processing
    
    .DESCRIPTION
    Export Office 365 Resource Mailboxes and Calendar Processing
    
    .PARAMETER Filter
    Provide specific mailboxes to report on.  Otherwise, all mailboxes will be reported.  Please review the examples provided.
    
    .PARAMETER DetailedReport
    Provides a full report of all attributes.  Otherwise, only a refined report will be given.
    
    .EXAMPLE
    Get-EXOResourceMailbox | Export-Csv c:\scripts\All365Mailboxes.csv -notypeinformation -encoding UTF8
    
    .EXAMPLE
    '{emailaddresses -like "*contoso.com"}' | Get-EXOResourceMailbox | Export-Csv c:\scripts\365ResourceMailboxes.csv -notypeinformation -encoding UTF8

    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, Mandatory = $false)]
        [string[]] $Filter
    )
    Begin {
        if ($Filter) {
            $AllUserMailboxes = Get-Mailbox -filter $CurFilter -ResultSize Unlimited -RecipientTypeDetails UserMailbox
            $MailboxLegacyExchangeDNHash = $AllUserMailboxes | Get-MailboxLegacyExchangeDNHash
        }
        else {
            $AllUserMailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox
            $MailboxLegacyExchangeDNHash = $AllUserMailboxes | Get-MailboxLegacyExchangeDNHash
        }

        $Selectproperties = @(
            'Identity', 'AdditionalResponse', 'AddAdditionalResponse', 'AddNewRequestsTentatively', 'AddOrganizerToSubject', 'AllBookInPolicy', 'AllowConflicts'
            'AllowRecurringMeetings', 'AllRequestInPolicy', 'AllRequestOutOfPolicy', 'DeleteAttachments', 'DeleteComments', 'DeleteNonCalendarItems'
            'DeleteSubject', 'EnableResponseDetails', 'EnforceSchedulingHorizon', 'ForwardRequestsToDelegates', 'IsValid', 'OrganizerInfo'
            'ProcessExternalMeetingMessages', 'RemoveForwardedMeetingNotifications', 'RemoveOldMeetingMessages', 'RemovePrivateProperty'
            'ScheduleOnlyDuringWorkHours', 'TentativePendingApproval', 'BookingWindowInDays', 'ConflictPercentageAllowed', 'MaximumConflictInstances'
            'MaximumDurationInMinutes', 'AutomateProcessing', 'MailboxOwnerId', 'ObjectState'
        )

        $CalculatedProps = @(
            @{n = "ResourceDelegates" ; e = {($_.ResourceDelegates | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "BookInPolicy" ; e = {($MailboxLegacyExchangeDNHash[$_.BookInPolicy] | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "RequestInPolicy" ; e = {($MailboxLegacyExchangeDNHash[$_.RequestInPolicy] | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "RequestOutOfPolicy" ; e = {($MailboxLegacyExchangeDNHash[$_.RequestOutOfPolicy] | Where-Object {$_ -ne $null}) -join ";" }}       
        )
    }
    Process {
        if ($Filter) {
            foreach ($CurFilter in $Filter) {
                Get-Mailbox -filter $CurFilter -RecipientTypeDetails roommailbox, equipmentmailbox -ResultSize unlimited | Get-CalendarProcessing | Select-Object ($Selectproperties + $CalculatedProps)
            }
        }
        else {
            Get-Mailbox -RecipientTypeDetails roommailbox, equipmentmailbox -ResultSize unlimited | Get-CalendarProcessing |  Select-Object ($Selectproperties + $CalculatedProps)
        }
    }
    End {
        
    }
}