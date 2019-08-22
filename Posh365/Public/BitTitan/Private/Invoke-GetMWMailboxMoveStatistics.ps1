function Invoke-GetMWMailboxMoveStatistics {
    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipeline)]
        $MailboxList
    )
    process {
        foreach ($Mailbox in $MailboxList) {
            Get-MW_MailboxStat -MailboxID $Mailbox.Id | Select-Object @(
                @{
                    Name       = 'Source'
                    Expression = { $Mailbox.ExportEmailAddress }
                }
                @{
                    Name       = 'Target'
                    Expression = { $Mailbox.ImportEmailAddress }
                }
                @{
                    Name       = 'RemainingGB'
                    Expression = { [Math]::Round([Double]($_.RemainingTransferSize) / 1GB, 4) }
                }
                @{
                    Name       = 'CurrentlyExported'
                    Expression = { $_.CurrentlyExportedFolderName }
                }
                @{
                    Name       = 'CurrentlyImported'
                    Expression = { $_.CurrentlyImportedFolderName }
                }
                'CreateDate'
            )
        }
    }
}
