Function Get-MailboxSyncStatistics {
    <#
    #>
    [CmdletBinding()]
    param
    (

    )

    $StatSplat = @{
        Title      = "Move Requests - Choose one or more and click OK for details"
        OutputMode = 'Multiple'
    }
    Import-MailboxSyncStatistics | Out-GridView @StatSplat
}
