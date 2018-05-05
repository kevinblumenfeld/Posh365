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
        [switch] $SkipConversionToResourceMailbox
    )
    Begin {

    }
    Process {
        ForEach ($CurResourceMailbox in $ResourceMailbox) {
            $sethash = @{
                Identity                            = $CurResourceMailbox.Identity
                AdditionalResponse                  = $CurResourceMailbox.AdditionalResponse
                AddAdditionalResponse               = [bool]::Parse($CurResourceMailbox.AddAdditionalResponse)
                AddNewRequestsTentatively           = [bool]::Parse($CurResourceMailbox.AddNewRequestsTentatively)
                AddOrganizerToSubject               = [bool]::Parse($CurResourceMailbox.AddOrganizerToSubject)
                AllBookInPolicy                     = [bool]::Parse($CurResourceMailbox.AllBookInPolicy)
                AllowConflicts                      = [bool]::Parse($CurResourceMailbox.AllowConflicts)
                AllowRecurringMeetings              = [bool]::Parse($CurResourceMailbox.AllowRecurringMeetings)
                AllRequestInPolicy                  = [bool]::Parse($CurResourceMailbox.AllRequestInPolicy)
                AllRequestOutOfPolicy               = [bool]::Parse($CurResourceMailbox.AllRequestOutOfPolicy)
                DeleteAttachments                   = [bool]::Parse($CurResourceMailbox.DeleteAttachments)
                DeleteComments                      = [bool]::Parse($CurResourceMailbox.DeleteComments)
                DeleteNonCalendarItems              = [bool]::Parse($CurResourceMailbox.DeleteNonCalendarItems)
                DeleteSubject                       = [bool]::Parse($CurResourceMailbox.DeleteSubject)
                EnableResponseDetails               = [bool]::Parse($CurResourceMailbox.EnableResponseDetails)
                EnforceSchedulingHorizon            = [bool]::Parse($CurResourceMailbox.EnforceSchedulingHorizon)
                ForwardRequestsToDelegates          = [bool]::Parse($CurResourceMailbox.ForwardRequestsToDelegates)
                OrganizerInfo                       = [bool]::Parse($CurResourceMailbox.OrganizerInfo)
                ProcessExternalMeetingMessages      = [bool]::Parse($CurResourceMailbox.ProcessExternalMeetingMessages)
                RemoveForwardedMeetingNotifications = [bool]::Parse($CurResourceMailbox.RemoveForwardedMeetingNotifications)
                RemoveOldMeetingMessages            = [bool]::Parse($CurResourceMailbox.RemoveOldMeetingMessages)
                RemovePrivateProperty               = [bool]::Parse($CurResourceMailbox.RemovePrivateProperty)
                ScheduleOnlyDuringWorkHours         = [bool]::Parse($CurResourceMailbox.ScheduleOnlyDuringWorkHours)
                TentativePendingApproval            = [bool]::Parse($CurResourceMailbox.TentativePendingApproval)
                BookingWindowInDays                 = $CurResourceMailbox.BookingWindowInDays
                ConflictPercentageAllowed           = $CurResourceMailbox.ConflictPercentageAllowed
                MaximumConflictInstances            = $CurResourceMailbox.MaximumConflictInstances
                MaximumDurationInMinutes            = $CurResourceMailbox.MaximumDurationInMinutes
                AutomateProcessing                  = $CurResourceMailbox.AutomateProcessing
            }  
            $setparams = @{}
            ForEach ($h in $sethash.keys) {
                if ($($sethash.item($h))) {
                    $setparams.add($h, $($sethash.item($h)))
                }
            }
            
            $type = $CurResourceMailbox.RecipientTypeDetails
            $convertType = @{}
            switch ( $type ) {
                RoomMailbox {
                    $convertType['Type'] = "Room"
                }
                EquipmentMailbox {
                    $convertType['Type'] = "Equipment"
                }
            }
            
            if (! $SkipConversionToResourceMailbox) {
                Set-Mailbox -Identity $CurResourceMailbox.Identity @convertType
            }
            Write-Verbose "Resource Mailbox: `t $($CurResourceMailbox.Identity)"
            Set-CalendarProcessing @setparams

            if ($CurResourceMailbox.ResourceDelegates) {
                $ResourceDelegateArray = [System.Collections.Generic.List[PSObject]]::new()
                $CurResourceMailbox.ResourceDelegates -Split ";" | ForEach-Object {
                    $ResourceDelegateArray.Add($_)                    
                }
                Set-CalendarProcessing -Identity $CurResourceMailbox.Identity -ResourceDelegates $ResourceDelegateArray
            }
            if ($CurResourceMailbox.BookInPolicy) {
                $BookInPolicyArray= [System.Collections.Generic.List[PSObject]]::new()
                $CurResourceMailbox.BookInPolicy -Split ";" | ForEach-Object {
                    $BookInPolicyArray.Add($_)
                }
                Set-CalendarProcessing -Identity $CurResourceMailbox.Identity -BookInPolicy $BookInPolicyArray
            }
            if ($CurResourceMailbox.RequestInPolicy) {
                $RequestInPolicyArray= [System.Collections.Generic.List[PSObject]]::new()
                $CurResourceMailbox.RequestInPolicy -Split ";" | ForEach-Object {
                    $RequestInPolicyArray.Add($_)
                }
                Set-CalendarProcessing -Identity $CurResourceMailbox.Identity -RequestInPolicy $RequestInPolicyArray
            }
            if ($CurResourceMailbox.RequestOutOfPolicy) {
                $RequestOutOfPolicyArray= [System.Collections.Generic.List[PSObject]]::new()
                $CurResourceMailbox.RequestOutOfPolicy -Split ";" | ForEach-Object {
                    $RequestOutOfPolicyArray.Add($_)
                }
                Set-CalendarProcessing -Identity $CurResourceMailbox.Identity -RequestOutOfPolicy $RequestOutOfPolicyArray
            }
        }
    }
    End {
        
    }
}
