Function Set-MailboxMove {
    <#
    .SYNOPSIS
    Set Mailbox Sync

    .DESCRIPTION
    Set Mailbox Sync

    .EXAMPLE
    Set-MailboxMove

    .EXAMPLE
    Set-MailboxMove -LargeItemLimit 400

    .EXAMPLE
    Set-MailboxMove -LargeItemLimit 400 -BadItemLimit 200 -SuspendWhenReadyToComplete

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param
    (
        [Parameter()]
        [switch]
        $SuspendWhenReadyToComplete,

        [Parameter()]
        [int]
        $LargeItemLimit,

        [Parameter()]
        [int]
        $BadItemLimit
    )

    end {
        $SetSplat = @{
            SuspendWhenReadyToComplete = $SuspendWhenReadyToComplete
        }
        if ($LargeItemLimit) {
            $SetSplat.Add('LargeItemLimit', $LargeItemLimit)
        }
        if ($BadItemLimit) {
            $SetSplat.Add('BadItemLimit', $BadItemLimit)
        }
        Invoke-SetMailboxMove @SetSplat | Out-GridView -Title "Results of Set Mailbox Sync"
    }
}
