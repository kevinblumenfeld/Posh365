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
        $OGVMR = @{
            Title      = 'Choose Mailboxes to Complete'
            OutputMode = 'Multiple'
        }

        $UserChoice = Get-MailboxSync | Sort-Object @(
            @{
                Expression = "BatchName"
                Descending = $true
            }
            @{
                Expression = "DisplayName"
                Descending = $false
            }
        ) | Out-GridView @OGVMR

        if ($UserChoice) {
            if ($Schedule) {
                $UTCTimeandDate = Get-ScheduleDecision
                $UserChoice | Resume-MailboxSync -Tenant $Tenant -CompleteAfter $UTCTimeandDate
            }
            else {
                $UserChoice | Resume-MailboxSync -Tenant $Tenant
            }

        }
    }
}

