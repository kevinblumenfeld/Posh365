Function Get-MailboxSync {
    <#
    .SYNOPSIS
    Get mailbox moves/syncs

    .DESCRIPTION
    Get mailbox moves/syncs

    .PARAMETER NotCompleted
    Use this switch to view all moves/syncs that are not completed

    .EXAMPLE
    Get-MailboxSync

    .EXAMPLE
    Get-MailboxSync | Out-GridView

    .EXAMPLE
    Get-MailboxSync -NotCompleted

    .EXAMPLE
    Get-MailboxSync -NotCompleted | Out-Gridview

    .NOTES
    General notes
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
        }
    }
    else {
        $MoveRequest = Get-MoveRequest -ResultSize 'Unlimited'
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
