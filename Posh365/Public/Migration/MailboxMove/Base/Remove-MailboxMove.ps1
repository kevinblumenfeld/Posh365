Function Remove-MailboxMove {
    <#
    .SYNOPSIS
    Remove Mailbox Move

    .DESCRIPTION
    Remove Mailbox Move

    .EXAMPLE
    Remove-MailboxMove

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
    if ($RemoveAndRestart) {
        $RandRObject = Get-MailboxMoveStatistics -RemoveAndRestart:$RemoveAndRestart  | Out-GridView -PassThru -Title 'Choose Mailboxes to Remove and Restart Moves'
        Invoke-RemoveMailboxMove -RandRObject $RandRObject | Out-GridView -Title "Results of Remove Mailbox Move"
        New-MailboxMove -RemoteHost $RandRObject[0].RemoteHostName -LargeItemLimit $LargeItemLimit -BadItemLimit $BadItemLimit -Object $RandRObject
    }
    else {
        Invoke-RemoveMailboxMove | Out-GridView -Title "Results of Remove Mailbox Move"
    }

}
