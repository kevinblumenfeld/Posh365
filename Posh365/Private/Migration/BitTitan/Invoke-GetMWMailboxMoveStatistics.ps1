function Invoke-GetMWMailboxMoveStatistics {
    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipeline)]
        $MailboxList
    )
    begin {
        $Now = [DateTime]::Now
    }
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
                    Name       = 'SinceCreated'
                    Expression = { '{0:dd}d {0:hh}h {0:mm}m' -f $Now.subtract(($_.CreateDate).ToLocalTime()) }
                }
                @{
                    Name       = 'SinceLastStart'
                    Expression = { '{0:dd}d {0:hh}h {0:mm}m' -f $Now.subtract(($_.LastStartDate).ToLocalTime()) }
                }
                @{
                    Name       = 'CurrentlyExported'
                    Expression = { $_.CurrentlyExportedFolderName }
                }
                @{
                    Name       = 'CurrentlyImported'
                    Expression = { $_.CurrentlyImportedFolderName }
                }
                @{
                    Name       = 'ExportDuration'
                    Expression = { [timespan]::new($_.ExportDuration) }
                }
                @{
                    Name       = 'ImportDuration'
                    Expression = { [timespan]::new($_.ImportDuration) }
                }
                @{
                    Name       = 'CreateDateLocal'
                    Expression = { (($_.CreateDate).ToLocalTime()) }
                }
                @{
                    Name       = 'Id'
                    Expression = { $Mailbox.Id }
                }
            )
        }
    }
}
