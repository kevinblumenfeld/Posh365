Function Invoke-GetMailboxMovePassThru {
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [switch]
        $IncludeCompleted,

        [Parameter()]
        [switch]
        $RemoveAndRestart
    )

    if ($IncludeCompleted) {
        Invoke-GetMailboxMove | Out-GridView -Title "All mailbox moves" -OutputMode Multiple
    }
    else {
        Invoke-GetMailboxMove -NotCompleted | Out-GridView -Title "All mailbox moves that are not yet complete" -OutputMode Multiple
    }
}
