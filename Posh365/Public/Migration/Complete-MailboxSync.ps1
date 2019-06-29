function Complete-MailboxSync {
    <#
    .SYNOPSIS
    Allows the completion or the scheduling of the completion of moves/syncs

    .DESCRIPTION
    Allows the completion or the scheduling of the completion of move requests

    .PARAMETER Tenant
    This is the tenant domain ex. if tenant is contoso.mail.onmicrosoft.com use contoso

    .PARAMETER Schedule
    A switch that allows you to choose a date and time at which to complete the mailbox moves/syncs

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>


    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Tenant,

        [Parameter()]
        [switch]
        $Schedule

    )
    end {
        if ($Tenant -notmatch '.mail.onmicrosoft.com') {
            $Tenant = "$Tenant.mail.onmicrosoft.com"
        }
        $UserChoice = Import-MailboxSyncNotCompleted

        if ($UserChoice -ne 'Quit' ) {
            if ($Schedule) {
                $UTCTimeandDate = Get-ScheduleDecision
                $UserChoice | Submit-MailboxSyncCompletion -Tenant $Tenant -CompleteAfter $UTCTimeandDate
            }
            else {
                $UserChoice | Submit-MailboxSyncCompletion -Tenant $Tenant
            }
        }
    }
}
