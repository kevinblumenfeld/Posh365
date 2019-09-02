function Invoke-GetBTUser {
    [CmdletBinding()]
    Param
    (

    )
    end {
        Get-BT_CustomerEndUser -Ticket $BitTitanTicket -RetrieveAll
    }
}
