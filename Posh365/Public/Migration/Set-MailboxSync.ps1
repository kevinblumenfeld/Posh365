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
    Set-MailboxSync -LargeItemLimit 400 -BadItemLimit 200

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param
    (
        [Parameter()]
        [int]
        $LargeItemLimit,

        [Parameter()]
        [int]
        $BadItemLimit
    )

    $UserChoice = Import-MailboxSyncDecision -NotCompleted
    if ($UserChoice -ne 'Quit' ) {
        $SetSplat = @{
            AcceptLargeDataLoss = $true
            Confirm             = $false
            warningaction       = 'silentlycontinue'
        }
        if ($LargeItemLimit) {
            $SetSplat.Add('LargeItemLimit', $LargeItemLimit)
        }
        if ($BadItemLimit) {
            $SetSplat.Add('BadItemLimit', $BadItemLimit)
        }
        foreach ($User in $UserChoice) {
            Set-MoveRequest -Identity $User.Guid @SetSplat
        }
    }
}
