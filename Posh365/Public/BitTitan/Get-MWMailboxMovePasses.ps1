function Get-MWMailboxMovePasses {
    [CmdletBinding()]
    Param
    (

    )
    end {
        Get-MWMailboxMove | Out-GridView -Title "Choose Mailboxes to report on Migration Wiz Passes" -PassThru |
        Invoke-GetMWMailboxMovePasses | Sort-Object -Property Source, StartDate | Out-GridView
    }
}
