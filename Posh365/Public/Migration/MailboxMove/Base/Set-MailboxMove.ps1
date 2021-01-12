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
        $BadItemLimit,

        [Parameter()]
        [switch]
        $DontAcceptLargeDataLoss
    )
    if ($TenantToTenant) {
        $SetSplat = @{ }
    }
    else {
        $SetSplat = @{
            SuspendWhenReadyToComplete = $SuspendWhenReadyToComplete
        }
    }
    if ($PSBoundParameters.ContainsKey('LargeItemLimit')) {
        $SetSplat.Add('LargeItemLimit', $LargeItemLimit)
    }
    if ($PSBoundParameters.ContainsKey('BadItemLimit')) {
        $SetSplat.Add('BadItemLimit', $BadItemLimit)
    }
    if ($DontAcceptLargeDataLoss) {
        $SetSplat.Add('AcceptLargeDataLoss', $false)
    }
    Invoke-SetMailboxMove @SetSplat | Out-GridView -Title "Results of Set Mailbox Move"
}
