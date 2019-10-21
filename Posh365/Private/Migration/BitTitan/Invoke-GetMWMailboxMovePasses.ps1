function Invoke-GetMWMailboxMovePasses {
    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipeline)]
        $MailboxList
    )
    process {
        foreach ($Mailbox in $MailboxList) {
            Get-MW_MailboxMigration -MailboxId $Mailbox.Id -RetrieveAll | Select-Object @(
                @{
                    Name       = 'Source'
                    Expression = { $Mailbox.Source }
                }
                @{
                    Name       = 'Target'
                    Expression = { $Mailbox.Target }
                }
                'Type'
                'Status'
                @{
                    Name       = 'FolderFilter'
                    Expression = { $Mailbox.FolderFilter }
                }
                @{
                    Name       = 'NumberOfDays'
                    Expression = { if ($_.Type -ne 'Verification') { (New-TimeSpan -Start $_.ItemEndDate -End (Get-Date)).Days } }
                }
                'ItemTypes'
                'StartDate'
                'CompleteDate'
                'FailureMessage'
            )
        }
    }
}
