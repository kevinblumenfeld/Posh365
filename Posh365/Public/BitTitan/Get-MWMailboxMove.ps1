function Get-MWMailboxMove {
    [CmdletBinding()]
    Param
    (

    )
    end {
        Invoke-GetMWMailboxMove | Select-Object @(
            @{
                Name       = 'Source'
                Expression = 'ExportEmailAddress'
            }
            @{
                Name       = 'Target'
                Expression = 'ImportEmailAddress'
            }
            @{
                Name       = 'Categories'
                Expression = { If ($_.Categories) { $StarColor[$_.Categories] } else { "" } }
            }
            'CreateDate'
            'Id'
        ) | Out-GridView -Title "MigrationWiz Mailbox Moves"
    }
}
