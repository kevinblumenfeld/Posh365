function Get-MWMailboxMoveStatistics {
    [CmdletBinding()]
    Param
    (

    )
    end {
        Invoke-GetMWMailboxMove | Invoke-GetMWMailboxMoveStatistics | Out-GridView -Title "MigrationWiz Mailbox Move Stats"
    }
}
