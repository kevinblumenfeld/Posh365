function Get-MWMailboxMove {
    [CmdletBinding()]
    Param
    (

    )
    end {
        Get-BT_Mailbox -ConnectorId $Connector.Id | Select-Object @(
            @{
                Name       = 'Source'
                Expression = 'ExportEmailAddress'
            }
            @{
                Name       = 'Target'
                Expression = 'ImportEmailAddress'
            }
            'Categories'
            'CreateDate'
            'Id'
        )
    }
}
