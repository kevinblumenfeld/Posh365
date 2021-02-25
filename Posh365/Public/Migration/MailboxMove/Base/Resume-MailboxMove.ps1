Function Resume-MailboxMove {
    <#
    .SYNOPSIS
    Resume Mailbox Move

    .DESCRIPTION
    Resume Mailbox Move

    .EXAMPLE
    Resume-MailboxMove

    .EXAMPLE
    Resume-MailboxMove -DontAutoComplete

    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [switch]
        $DontAutoComplete
    )

    $UserChoice = Get-MailboxMoveStatistics -PassThruData | Out-GridView -PassThru -Title 'Choose Mailbox Move(s) to Resume'
    if ($UserChoice) {
        Invoke-ResumeMailboxMove -UserChoice $UserChoice -DontAutoComplete:$DontAutoComplete | Out-GridView -Title "Results of Resume Mailbox Move"
    }
}
