function Complete-MailboxMove {
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

        [Parameter()]
        [switch]
        $Schedule,

        [Parameter()]
        [switch]
        $TenantToTenant

    )
    $UserChoice = Import-MailboxMoveDecision -NotCompleted
    if ($UserChoice -ne 'Quit' ) {
        if ($TenantToTenant) {
            $UserChoice | Invoke-T2TCompleteMailboxMove | Out-GridView -Title "Completion of Tenant To Tenant mailbox move results"
            return
        }
        if ($Schedule) {
            $UTCTimeandDate = Get-ScheduleDecision
            $UserChoice | Invoke-CompleteMailboxMove -CompleteAfter $UTCTimeandDate | Out-GridView -Title "Scheduling of complete mailbox move results"
        }
        else {
            $UserChoice | Invoke-CompleteMailboxMove | Out-GridView -Title "Completion of mailbox move results"
        }
    }
}
