function Get-ExchangeMailboxStatistics {
    <#

    #>
    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipeline = $true, Mandatory = $false)]
        $Mailbox
    )
    Begin {

    }
    Process {
        foreach ($CurMailbox in $Mailbox) {
            $ArchiveGB = Get-MailboxStatistics -identity $CurMailbox.PrimarySmtpAddress -Archive -ErrorAction SilentlyContinue | ForEach-Object {
                [Math]::Round([Double]($_.TotalItemSize -replace '^.*\(| .+$|,') / 1GB, 5)
            }
            Get-MailboxStatistics -identity $CurMailbox.PrimarySmtpAddress | Select-Object @(
                'DisplayName'
                @{
                    Name       = 'MailboxGB'
                    Expression = {
                        [Math]::Round([Double]($_.TotalItemSize -replace '^.*\(| .+$|,') / 1GB, 5)
                    }
                }
                @{
                    Name       = 'ArchiveGB'
                    Expression = { $ArchiveGB }
                }
                @{
                    Name       = 'TotalGB'
                    Expression = {
                        [Math]::Round([Double]($_.TotalItemSize -replace '^.*\(| .+$|,') / 1GB, 5) + $ArchiveGB
                    }
                }
                'LastLogonTime'
                'ItemCount'
            )
        }
    }
    End {

    }
}


