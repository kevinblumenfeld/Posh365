function Get-MWMailboxMoveStatistics {
    [CmdletBinding()]
    Param
    (

    )
    end {
        Invoke-GetMWMailboxMove | Invoke-GetMWMailboxMoveStatistics
    }
}
