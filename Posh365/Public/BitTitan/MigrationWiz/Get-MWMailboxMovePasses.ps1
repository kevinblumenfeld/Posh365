function Get-MWMailboxMovePasses {
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
        ) | Out-GridView -Title "Choose Mailboxes to report on Migration Wiz Passes" -PassThru |
        Invoke-GetMWMailboxMovePasses | Sort-Object -Property Source, StartDate | Out-GridView
    }
}
