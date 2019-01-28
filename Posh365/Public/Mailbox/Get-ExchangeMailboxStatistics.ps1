function Get-ExchangeMailboxStatistics {
    <#

    #>
    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $false)]
        [Microsoft.Exchange.Data.Directory.Management.Mailbox] $Mailbox
    )
    Begin {

    }
    Process {
        foreach ($CurMailbox in $Mailbox) {
            $ArchiveGB = $CurMailbox | Get-MailboxStatistics -Archive -ErrorAction SilentlyContinue | ForEach-Object {
                [Math]::Round([Int]($_.TotalItemSize -replace '^.*\(| .+$|,') / 1GB, 5)
            }
            $CurMailbox | Get-MailboxStatistics | Select-Object @(
                'DisplayName'
                @{
                    Name       = 'MailboxGB'
                    Expression = {
                        [Math]::Round([Int]($_.TotalItemSize -replace '^.*\(| .+$|,') / 1GB, 5)
                    }
                }
                @{
                    Name       = 'ArchiveGB'
                    Expression = { $ArchiveGB }
                }
                @{
                    Name       = 'TotalGB'
                    Expression = {
                        [Math]::Round([Int]($_.TotalItemSize -replace '^.*\(| .+$|,') / 1GB, 5) + $ArchiveGB
                    }
                }
                'LastLogonTime'
            )
        }
    }
    End {

    }
}