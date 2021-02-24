Function Remove-MailboxMove {
    <#
    .SYNOPSIS
    Remove Mailbox Move

    .DESCRIPTION
    Remove Mailbox Move.  Optionally restarts them as well.

    .PARAMETER RemoveAndRestart
    After removing the move, it restarts it

    .PARAMETER BadItemLimit
    Default is 20

    .PARAMETER LargeItemLimit
    Default is 20

    .EXAMPLE
    Remove-MailboxMove

    .EXAMPLE
    Remove-MailboxMove -RemoveAndRestart

    .NOTES
    General notes

    #>
    [CmdletBinding(DefaultParameterSetName = 'PlaceHolder')]
    param (
        [Parameter(ParameterSetName = 'RandR')]
        [switch]
        $RemoveAndRestart,

        [Parameter(ParameterSetName = 'RandR')]
        [ValidateNotNullOrEmpty()]
        [int]
        $BadItemLimit = 20,

        [Parameter(ParameterSetName = 'RandR')]
        [ValidateNotNullOrEmpty()]
        [int]
        $LargeItemLimit = 20
    )

    $RandRObject = Get-MailboxMoveStatistics -RemoveAndRestart:$RemoveAndRestart -remove | Out-GridView -PassThru -Title 'Choose Mailboxes to Remove'
    Invoke-RemoveMailboxMove -RandRObject $RandRObject | Out-GridView -Title "Results of Remove Mailbox Move"
    if ($RemoveAndRestart) {
        New-MailboxMove -Object $RandRObject -RemoteHost $RandRObject[0].RemoteHostName -LargeItemLimit $LargeItemLimit -BadItemLimit $BadItemLimit
    }

}
