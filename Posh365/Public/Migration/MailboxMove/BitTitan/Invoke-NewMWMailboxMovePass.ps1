function Invoke-NewMWMailboxMovePass {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $MailboxChoice,

        [Parameter(Mandatory)]
        $ItemTypes,

        [Parameter()]
        $NumberofDays
    )
    begin {

    }
    process {
        foreach ($Mailbox in $MailboxChoice) {
            $PassSplat = @{
                Ticket      = $MigWizTicket
                ConnectorId = $MWProject.Id
                MailboxId   = $Mailbox.Id
                UserId      = $MigWizTicket.UserId
                Type        = 'Full'
                ItemTypes   = $ItemTypes
                ItemEndDate = ((Get-Date).AddDays(-$NumberofDays))
                ErrorAction = 'Stop'
            }
            try {
                $Result = Add-MW_MailboxMigration @PassSplat
                [PSCustomObject]@{
                    'Source'       = $Mailbox.Source
                    'Target'       = $Mailbox.Target
                    'Type'         = 'Full'
                    'NumberofDays' = $NumberofDays
                    'ItemTypes'    = $ItemTypes
                    'Result'       = 'SUCCESS'
                    'Log'          = 'SUCCESS'
                    'Action'       = 'MIGRATE'
                    'Id'           = $Result.Id
                }
            }
            catch {
                [PSCustomObject]@{
                    'Source'       = $Mailbox.Source
                    'Target'       = $Mailbox.Target
                    'Type'         = 'Full'
                    'NumberofDays' = $NumberofDays
                    'ItemTypes'    = @($ItemTypes) -ne '' -join ','
                    'Result'       = 'FAILED'
                    'Log'          = $_.Exception.Message
                    'Action'       = 'MIGRATE'
                    'Id'           = ''
                }
            }
        }
    }
}
