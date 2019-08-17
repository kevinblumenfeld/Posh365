function Get-MWMailbox {
    [CmdletBinding()]
    Param
    (

    )
    end {
        Get-MW_Mailbox -ConnectorId $Connector.Id
    }
}
