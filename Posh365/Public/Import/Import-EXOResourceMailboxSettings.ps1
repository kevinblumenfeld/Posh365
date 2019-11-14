function Import-EXOResourceMailboxSettings {
    <#
    .SYNOPSIS
    Convert User Mailbox to Room or Equipment Mailbox and add specific settings

    .DESCRIPTION
    Convert User Mailbox to Room or Equipment Mailbox and add specific settings

    .PARAMETER SkipConversionToResourceMailbox
    Skips the conversion to a resource mailbox.

    .EXAMPLE
    Import-Csv .\contoso-EXOResourceMailbox.csv | Import-EXOResourceMailboxSettings


    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $ResourceMailbox,

        [Parameter(Mandatory = $false)]
        [switch]
        $SkipConversionToResourceMailbox
    )
    Begin {

    }
    Process {
        ForEach ($Resource in $ResourceMailbox) {
            $sethash = @{
                Identity                            = $Resource.Identity
                AdditionalResponse                  = $Resource.AdditionalResponse
                AddAdditionalResponse               = [bool]::Parse($Resource.AddAdditionalResponse)
                AddNewRequestsTentatively           = [bool]::Parse($Resource.AddNewRequestsTentatively)
                AddOrganizerToSubject               = [bool]::Parse($Resource.AddOrganizerToSubject)
                AllBookInPolicy                     = [bool]::Parse($Resource.AllBookInPolicy)
                AllowConflicts                      = [bool]::Parse($Resource.AllowConflicts)
                AllowRecurringMeetings              = [bool]::Parse($Resource.AllowRecurringMeetings)
                AllRequestInPolicy                  = [bool]::Parse($Resource.AllRequestInPolicy)
                AllRequestOutOfPolicy               = [bool]::Parse($Resource.AllRequestOutOfPolicy)
                DeleteAttachments                   = [bool]::Parse($Resource.DeleteAttachments)
                DeleteComments                      = [bool]::Parse($Resource.DeleteComments)
                DeleteNonCalendarItems              = [bool]::Parse($Resource.DeleteNonCalendarItems)
                DeleteSubject                       = [bool]::Parse($Resource.DeleteSubject)
                EnableResponseDetails               = [bool]::Parse($Resource.EnableResponseDetails)
                EnforceSchedulingHorizon            = [bool]::Parse($Resource.EnforceSchedulingHorizon)
                ForwardRequestsToDelegates          = [bool]::Parse($Resource.ForwardRequestsToDelegates)
                OrganizerInfo                       = [bool]::Parse($Resource.OrganizerInfo)
                ProcessExternalMeetingMessages      = [bool]::Parse($Resource.ProcessExternalMeetingMessages)
                RemoveForwardedMeetingNotifications = [bool]::Parse($Resource.RemoveForwardedMeetingNotifications)
                RemoveOldMeetingMessages            = [bool]::Parse($Resource.RemoveOldMeetingMessages)
                RemovePrivateProperty               = [bool]::Parse($Resource.RemovePrivateProperty)
                ScheduleOnlyDuringWorkHours         = [bool]::Parse($Resource.ScheduleOnlyDuringWorkHours)
                TentativePendingApproval            = [bool]::Parse($Resource.TentativePendingApproval)
                BookingWindowInDays                 = $Resource.BookingWindowInDays
                ConflictPercentageAllowed           = $Resource.ConflictPercentageAllowed
                MaximumConflictInstances            = $Resource.MaximumConflictInstances
                MaximumDurationInMinutes            = $Resource.MaximumDurationInMinutes
                AutomateProcessing                  = $Resource.AutomateProcessing
            }
            $setparams = @{ }
            ForEach ($h in $sethash.keys) {
                if ($($sethash.item($h))) {
                    $setparams.add($h, $($sethash.item($h)))
                }
            }

            $type = $Resource.RecipientTypeDetails
            $convertType = @{ }
            switch ( $type ) {
                RoomMailbox {
                    $convertType['Type'] = "Room"
                }
                EquipmentMailbox {
                    $convertType['Type'] = "Equipment"
                }
            }

            if (-not $SkipConversionToResourceMailbox) {
                Set-Mailbox -Identity $Resource.Identity @convertType
            }
            Write-Verbose "Resource Mailbox: `t $($Resource.Identity)"
            Set-CalendarProcessing @setparams

            if ($Resource.ResourceDelegates) {
                Set-CalendarProcessing -Identity $Resource.Identity -ResourceDelegates ($Resource.ResourceDelegates -split [regex]::Escape('|'))
            }
            if ($Resource.BookInPolicy) {
                Set-CalendarProcessing -Identity $Resource.Identity -BookInPolicy $Resource.BookInPolicy -split [regex]::Escape('|')
            }
            if ($Resource.RequestInPolicy) {
                Set-CalendarProcessing -Identity $Resource.Identity -RequestInPolicy ($Resource.RequestInPolicy -split [regex]::Escape('|'))
            }
            if ($Resource.RequestOutOfPolicy) {
                Set-CalendarProcessing -Identity $Resource.Identity -RequestOutOfPolicy ($Resource.RequestOutOfPolicy -split [regex]::Escape('|'))
            }
        }
    }
    End {

    }
}
