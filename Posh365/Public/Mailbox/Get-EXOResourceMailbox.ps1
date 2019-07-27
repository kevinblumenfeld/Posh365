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
        [string[]] $Filter,

        [Parameter()]
        $ResourceMailbox
    )
    begin {
        $MailboxProperties = @(
            'DisplayName', 'Office', 'RecipientTypeDetails', 'UserPrincipalName', 'Identity', 'PrimarySmtpAddress', 'Alias'
        )
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
            @{n = "ResourceDelegates" ; e = { @($MailboxLegacyExchangeDNHash[$_.ResourceDelegates]) -ne '' -join '|' } },
            @{n = "BookInPolicy" ; e = { @($MailboxLegacyExchangeDNHash[$_.BookInPolicy]) -ne '' -join '|' } },
            @{n = "RequestInPolicy" ; e = { @($MailboxLegacyExchangeDNHash[$_.RequestInPolicy]) -ne '' -join '|' } },
            @{n = "RequestOutOfPolicy" ; e = { @($MailboxLegacyExchangeDNHash[$_.RequestOutOfPolicy]) -ne '' -join '|' } }
        )
    }
    process {
        if (-not $ResourceMailbox) {
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
        else {
            foreach ($Resource in $ResourceMailbox) {
                $CalList = Get-CalendarProcessing -Identity $Resource.Guid.ToString()
                foreach ($Cal in $CalList) {
                    [PSCustomObject]@{
                        DisplayName                         = $Resource.DisplayName
                        Office                              = $Resource.Office
                        RecipientTypeDetails                = $Resource.RecipientTypeDetails
                        Identity                            = $Resource.Identity
                        PrimarySmtpAddress                  = $Resource.PrimarySmtpAddress
                        Alias                               = $Resource.Alias
                        TotalGB                             = $Resource.TotalGB
                        ResourceDelegates                   = $Cal.ResourceDelegates
                        MaximumDurationInMinutes            = $Cal.MaximumDurationInMinutes
                        AutomateProcessing                  = $Cal.AutomateProcessing
                        MailboxOwnerId                      = $Cal.MailboxOwnerId
                        BookingWindowInDays                 = $Cal.BookingWindowInDays
                        ConflictPercentageAllowed           = $Cal.ConflictPercentageAllowed
                        MaximumConflictInstances            = $Cal.MaximumConflictInstances
                        AdditionalResponse                  = $Cal.AdditionalResponse
                        AddAdditionalResponse               = $Cal.AddAdditionalResponse
                        AddNewRequestsTentatively           = $Cal.AddNewRequestsTentatively
                        AddOrganizerToSubject               = $Cal.AddOrganizerToSubject
                        AllBookInPolicy                     = $Cal.AllBookInPolicy
                        AllowConflicts                      = $Cal.AllowConflicts
                        AllowRecurringMeetings              = $Cal.AllowRecurringMeetings
                        AllRequestInPolicy                  = $Cal.AllRequestInPolicy
                        AllRequestOutOfPolicy               = $Cal.AllRequestOutOfPolicy
                        DeleteAttachments                   = $Cal.DeleteAttachments
                        DeleteComments                      = $Cal.DeleteComments
                        DeleteNonCalendarItems              = $Cal.DeleteNonCalendarItems
                        DeleteSubject                       = $Cal.DeleteSubject
                        EnableResponseDetails               = $Cal.EnableResponseDetails
                        EnforceSchedulingHorizon            = $Cal.EnforceSchedulingHorizon
                        ForwardRequestsToDelegates          = $Cal.ForwardRequestsToDelegates
                        IsValid                             = $Cal.IsValid
                        OrganizerInfo                       = $Cal.OrganizerInfo
                        ProcessExternalMeetingMessages      = $Cal.ProcessExternalMeetingMessages
                        RemoveForwardedMeetingNotifications = $Cal.RemoveForwardedMeetingNotifications
                        RemoveOldMeetingMessages            = $Cal.RemoveOldMeetingMessages
                        RemovePrivateProperty               = $Cal.RemovePrivateProperty
                        ScheduleOnlyDuringWorkHours         = $Cal.ScheduleOnlyDuringWorkHours
                        TentativePendingApproval            = $Cal.TentativePendingApproval
                        ObjectState                         = $Cal.ObjectState
                        BookInPolicy                        = $Cal.BookInPolicy
                        RequestInPolicy                     = $Cal.RequestInPolicy
                        RequestOutOfPolicy                  = $Cal.RequestOutOfPolicy
                    }
                }
            }
        }
    }
    end {

    }
}
