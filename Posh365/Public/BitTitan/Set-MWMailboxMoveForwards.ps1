function Set-MWMailboxMoveForward {
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [switch]
        $DeliverAndForward
    )
    end {
        $SetParams = @{
            'DeliverAndForward' = $DeliverAndForward
        }
        Invoke-SetMWMailboxMoveForward @SetParams | Out-GridView -Title "Results of Setting Mailbox Forwards for a MigrationWiz Mailbox Move"
    }
}
