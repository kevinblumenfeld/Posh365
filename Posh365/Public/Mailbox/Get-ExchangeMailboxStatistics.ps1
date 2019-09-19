function Get-ExchangeMailboxStatistics {
    <#
    .SYNOPSIS
    Get Exchange Mailbox Statistics using GB's as the unit of measurement

    .DESCRIPTION
    Get Exchange Mailbox Statistics using GB's as the unit of measurement.
    Includes Archive Mailbox and Total of both standard and archive mailbox.
    Item Count does not include archive mailbox.

    .PARAMETER Mailbox
    This is only via Pipeline input.  See examples below.

    .EXAMPLE
    Get-Mailbox | Get-ExchangeMailboxStatistics

    .EXAMPLE
    Import-Csv .\primarysmtpaddress.csv | % {Get-Mailbox $_.PrimarySmtpAddress} | Get-ExchangeMailboxStatistics

    .NOTES
    Csv must contain header named PrimarySMTPAddress
    #>

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


