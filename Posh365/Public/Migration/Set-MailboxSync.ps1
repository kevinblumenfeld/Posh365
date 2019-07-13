Function Set-MailboxSync {
    <#
    .SYNOPSIS
    Set Mailbox Sync

    .DESCRIPTION
    Set Mailbox Sync

    .EXAMPLE
    Set-MailboxSync

    .EXAMPLE
    Set-MailboxSync -LargeItemLimit 400

    .EXAMPLE
    Set-MailboxSync -LargeItemLimit 400 -BadItemLimit 200 -SuspendWhenReadyToComplete

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
        Invoke-SetMailboxSync @SetSplat | Out-GridView -Title "Results of Set Mailbox Sync"
    }
}
