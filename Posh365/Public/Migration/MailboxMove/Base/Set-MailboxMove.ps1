Function Set-MailboxMove {
    <#
    .SYNOPSIS
    Set Mailbox Move

    .DESCRIPTION
    Set Mailbox Move

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
        $TenantToTenant,

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
    if ($TenantToTenant) {
        $SetSplat = @{ }
    }
    else {
        $SetSplat = @{
            SuspendWhenReadyToComplete = $SuspendWhenReadyToComplete
        }
    }
    if ($LargeItemLimit) {
        $SetSplat.Add('LargeItemLimit', $LargeItemLimit)
    }
    if ($BadItemLimit) {
        $SetSplat.Add('BadItemLimit', $BadItemLimit)
    }
    Invoke-SetMailboxMove @SetSplat | Out-GridView -Title "Results of Set Mailbox Move"
}
