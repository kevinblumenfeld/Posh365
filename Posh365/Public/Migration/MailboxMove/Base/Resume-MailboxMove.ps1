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
    end {
        if ($DontAutoComplete) {
            Invoke-ResumeMailboxMove -DontAutoComplete | Out-GridView -Title "Results of Resume Mailbox Move (SuspendWhenReadyToComplete=True)"
        }
        else {
            Invoke-ResumeMailboxMove | Out-Gridview -Title "Results of Resume Mailbox Move"
        }
    }
}
