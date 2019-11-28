function Get-OnPremExchangeMailboxStatistics {
    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Mandatory = $false)]
        $MailboxList
    )
    Begin {

    }
    Process {
        foreach ($Mailbox in $MailboxList) {
            $ArchiveGB = Get-MailboxStatistics -identity ($Mailbox.Guid).ToString() -Archive -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | ForEach-Object {
                [Math]::Round([Double]($_.TotalItemSize -replace '^.*\(| .+$|,') / 1GB, 4)
            }
            Get-MailboxStatistics -identity ($Mailbox.Guid).ToString() -WarningAction SilentlyContinue | Select-Object @(
                'DisplayName'
                @{
                    Name       = 'PrimarySmtpAddress'
                    Expression = { $Mailbox.PrimarySmtpAddress }
                }
                @{
                    Name       = 'UserPrincipalName'
                    Expression = { $Mailbox.UserPrincipalName }
                }
                @{
                    Name       = 'MailboxGB'
                    Expression = {
                        [Math]::Round([Double]($_.TotalItemSize -replace '^.*\(| .+$|,') / 1GB, 4)
                    }
                }
                @{
                    Name       = 'ArchiveGB'
                    Expression = { $ArchiveGB }
                }
                @{
                    Name       = 'DeletedGB'
                    Expression = {
                        [Math]::Round([Double]($_.TotalDeletedItemSize -replace '^.*\(| .+$|,') / 1GB, 4)
                    }
                }
                @{
                    Name       = 'TotalGB'
                    Expression = {
                        [Math]::Round([Double]($_.TotalItemSize -replace '^.*\(| .+$|,') / 1GB, 4) + $ArchiveGB
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
