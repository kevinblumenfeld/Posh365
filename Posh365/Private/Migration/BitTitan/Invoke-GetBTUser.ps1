function Invoke-GetBTUser {
    [CmdletBinding()]
    Param
    (

    )
    end {
        Get-BT_CustomerEndUser -Ticket $BitTic -IsDeleted:$false -RetrieveAll:$true
    }
}
