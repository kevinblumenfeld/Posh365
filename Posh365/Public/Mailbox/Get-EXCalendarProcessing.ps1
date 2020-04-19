function Get-EXCalendarProcessing {
    <#
    .SYNOPSIS
    Export a list of mailbox calendar processing settings

    .DESCRIPTION
    Export a list of mailbox calendar processing settings

    .PARAMETER MailboxXML
    Parameter description

    .PARAMETER MailUserXML
    Parameter description

    .PARAMETER MailContactXML
    Parameter description

    .PARAMETER DistributionGroupXML
    Parameter description

    .PARAMETER SleepinMilliseconds
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path -Path $_ })]
        $MailboxXML,

        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path -Path $_ })]
        $MailUserXML,

        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path -Path $_ })]
        $MailContactXML,

        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path -Path $_ })]
        $DistributionGroupXML,

        [Parameter()]
        $SleepinMilliseconds = 500
    )

    $MailboxList = Import-Clixml $MailboxXML
    $MailUser = Import-Clixml $MailUserXML
    $MailContact = Import-Clixml $MailContactXML
    $DistributionGroup = Import-Clixml $DistributionGroupXML
    $LegDNHash = Get-LegacyDNHash -Mailbox $MailboxList -MailUser $MailUser -MailContact $MailContact -DistributionGroup $DistributionGroup
    $i = 0
    $Count = $MailboxList.Count
    foreach ($Mailbox in $MailboxList) {
        $i++
        Write-Host "[$i of $Count]  " -ForegroundColor White -NoNewline
        Write-Host "$($Mailbox.DisplayName)" -ForegroundColor Cyan
        Start-Sleep -Milliseconds $SleepinMilliseconds
        $CalList = Get-CalendarProcessing -Identity $Mailbox.Guid.ToString()
        foreach ($Cal in $CalList) {
            [PSCustomObject]@{
                DisplayName                         = $Mailbox.DisplayName
                Office                              = $Mailbox.Office
                RecipientTypeDetails                = $Mailbox.RecipientTypeDetails
                Identity                            = $Mailbox.Identity
                PrimarySmtpAddress                  = $Mailbox.PrimarySmtpAddress
                Alias                               = $Mailbox.Alias
                AutomateProcessing                  = $Cal.AutomateProcessing
                ResourceDelegates                   = @($Cal.ResourceDelegates) -ne '' -join '|'
                AllBookInPolicy                     = $Cal.AllBookInPolicy
                AllRequestInPolicy                  = $Cal.AllRequestInPolicy
                BookInPolicy                        = @($Cal.BookInPolicy) -ne '' | ForEach-Object { $LegDNHash[$_] -join '|' }
                RequestInPolicy                     = @($Cal.RequestInPolicy) -ne '' | ForEach-Object { $LegDNHash[$_] -join '|' }
                RequestOutOfPolicy                  = @($Cal.RequestOutOfPolicy) -ne '' | ForEach-Object { $LegDNHash[$_] -join '|' }
                AllRequestOutOfPolicy               = $Cal.AllRequestOutOfPolicy
                TotalGB                             = $Mailbox.TotalGB
                MaximumDurationInMinutes            = $Cal.MaximumDurationInMinutes
                BookingWindowInDays                 = $Cal.BookingWindowInDays
                ConflictPercentageAllowed           = $Cal.ConflictPercentageAllowed
                MaximumConflictInstances            = $Cal.MaximumConflictInstances
                AdditionalResponse                  = $Cal.AdditionalResponse
                AddAdditionalResponse               = $Cal.AddAdditionalResponse
                AddNewRequestsTentatively           = $Cal.AddNewRequestsTentatively
                ForwardRequestsToDelegates          = $Cal.ForwardRequestsToDelegates
                TentativePendingApproval            = $Cal.TentativePendingApproval
                AddOrganizerToSubject               = $Cal.AddOrganizerToSubject
                AllowConflicts                      = $Cal.AllowConflicts
                AllowRecurringMeetings              = $Cal.AllowRecurringMeetings
                DeleteAttachments                   = $Cal.DeleteAttachments
                DeleteComments                      = $Cal.DeleteComments
                DeleteNonCalendarItems              = $Cal.DeleteNonCalendarItems
                DeleteSubject                       = $Cal.DeleteSubject
                EnableResponseDetails               = $Cal.EnableResponseDetails
                EnforceSchedulingHorizon            = $Cal.EnforceSchedulingHorizon
                IsValid                             = $Cal.IsValid
                OrganizerInfo                       = $Cal.OrganizerInfo
                ProcessExternalMeetingMessages      = $Cal.ProcessExternalMeetingMessages
                RemoveForwardedMeetingNotifications = $Cal.RemoveForwardedMeetingNotifications
                RemoveOldMeetingMessages            = $Cal.RemoveOldMeetingMessages
                RemovePrivateProperty               = $Cal.RemovePrivateProperty
                ScheduleOnlyDuringWorkHours         = $Cal.ScheduleOnlyDuringWorkHours
                ObjectState                         = $Cal.ObjectState
                MailboxOwnerId                      = $Cal.MailboxOwnerId
            }
        }
    }
}
