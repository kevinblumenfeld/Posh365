Function Invoke-GetMailboxMove {
    <#
    .SYNOPSIS
    Get Mailbox Moves

    .DESCRIPTION
    Get Mailbox Moves

    .PARAMETER NotCompleted
    Use this switch to view only Mailbox Moves that have yet to be completed

    .EXAMPLE
    Get-MailboxMove

    .EXAMPLE
    Get-MailboxMove | Out-GridView

    .EXAMPLE
    Get-MailboxMove -NotCompleted

    .EXAMPLE
    Get-MailboxMove -NotCompleted | Out-Gridview

    .NOTES
    Connect to Exchange Online
    #>

    [CmdletBinding()]
    param
    (
        [Parameter()]
        [switch]
        $NotCompleted
    )

    if ($NotCompleted) {
        $MoveRequest = Get-MoveRequest -ResultSize 'Unlimited' | Where-Object {
            $_.Status -ne 'Completed' -and $_.Status -ne 'CompletedWithWarning'
        } | Sort-Object -Property Identity
    }
    else {
        $MoveRequest = Get-MoveRequest -ResultSize 'Unlimited' | Sort-Object -Property Identity
    }
    foreach ($Move in $MoveRequest) {
        [PSCustomObject]@{
            Identity                   = $Move.Identity
            Status                     = $Move.Status
            DisplayName                = $Move.DisplayName
            Alias                      = $Move.Alias
            BatchName                  = $Move.BatchName
            Suspend                    = $Move.Suspend
            SuspendWhenReadyToComplete = $Move.SuspendWhenReadyToComplete
            RecipientType              = $Move.RecipientType
            RecipientTypeDetails       = $Move.RecipientTypeDetails
            RemoteHostName             = $Move.RemoteHostName
            RequestStyle               = $Move.RequestStyle
            TargetDatabase             = $Move.TargetDatabase
            ExchangeGuid               = $Move.ExchangeGuid
            Guid                       = $Move.Guid
            Name                       = $Move.Name
        }
    }
}
