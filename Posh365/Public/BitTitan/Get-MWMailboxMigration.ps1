function Get-MWMailboxMigration {
    [CmdletBinding()]
    Param
    (

    )
    end {
        Get-MW_MailboxMigration -ConnectorId $Connector.Id
    }
}
