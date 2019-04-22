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
            $AllUserMailboxes = Get-Mailbox -filter $CurFilter -RecipientTypeDetails RoomMailbox, EquipmentMailbox -ResultSize Unlimited
            $MailboxLegacyExchangeDNHash = $AllUserMailboxes | Get-MailboxLegacyExchangeDNHash
        }
        else {
            $AllUserMailboxes = Get-Mailbox -RecipientTypeDetails RoomMailbox, EquipmentMailbox -ResultSize Unlimited
            $MailboxLegacyExchangeDNHash = $AllUserMailboxes | Get-MailboxLegacyExchangeDNHash
        }

        $Selectproperties = @(
            'Identity', 'RecipientTypeDetails', 'AdditionalResponse', 'AddAdditionalResponse', 'AddNewRequestsTentatively', 'AddOrganizerToSubject', 'AllBookInPolicy', 'AllowConflicts'
            'AllowRecurringMeetings', 'AllRequestInPolicy', 'AllRequestOutOfPolicy', 'DeleteAttachments', 'DeleteComments', 'DeleteNonCalendarItems'
            'DeleteSubject', 'EnableResponseDetails', 'EnforceSchedulingHorizon', 'ForwardRequestsToDelegates', 'IsValid', 'OrganizerInfo'
            'ProcessExternalMeetingMessages', 'RemoveForwardedMeetingNotifications', 'RemoveOldMeetingMessages', 'RemovePrivateProperty'
            'ScheduleOnlyDuringWorkHours', 'TentativePendingApproval', 'BookingWindowInDays', 'ConflictPercentageAllowed', 'MaximumConflictInstances'
            'MaximumDurationInMinutes', 'AutomateProcessing', 'MailboxOwnerId', 'ObjectState'
        )

        $CalculatedProps = @(
            @{n = "ResourceDelegates" ; e = { [string]::join("|", [String[]]$_.ResourceDelegates -ne '') } },
            @{n = "BookInPolicy" ; e = { [string]::join("|", [String[]]$MailboxLegacyExchangeDNHash[$_.BookInPolicy] -ne '') } },
            @{n = "RequestInPolicy" ; e = { [string]::join("|", [String[]]$MailboxLegacyExchangeDNHash[$_.RequestInPolicy] -ne '') } },
            @{n = "RequestOutOfPolicy" ; e = { [string]::join("|", [String[]]$MailboxLegacyExchangeDNHash[$_.RequestOutOfPolicy] -ne '') } }
        )
    }
    Process {
        if ($Filter) {
            foreach ($CurFilter in $Filter) {
                Get-Mailbox -filter $CurFilter -RecipientTypeDetails RoomMailbox, EquipmentMailbox -ResultSize Unlimited |
                Get-CalendarProcessing | Select-Object ($Selectproperties + $CalculatedProps)
            }
        }
        else {
            Get-Mailbox -RecipientTypeDetails RoomMailbox, EquipmentMailbox -ResultSize Unlimited |
            Get-CalendarProcessing | Select-Object ($Selectproperties + $CalculatedProps)
        }
    }
    End {

    }
}