function Get-MWMailboxConnector {
    [CmdletBinding()]
    Param
    (

    )
    end {
        Get-MW_MailboxConnector -Ticket $MWTicket
    }
}
