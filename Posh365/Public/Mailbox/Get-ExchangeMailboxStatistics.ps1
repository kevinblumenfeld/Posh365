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

        [Parameter(ValueFromPipeline = $true, Mandatory = $false)]
        $MailboxList
    )
    Begin {

    }
    Process {
        foreach ($Mailbox in $MailboxList) {
            $ArchiveGB = Get-MailboxStatistics -identity ($Mailbox.PrimarySmtpAddress).ToString() -Archive -ErrorAction SilentlyContinue | ForEach-Object {
                [Math]::Round([Double]($_.TotalItemSize -replace '^.*\(| .+$|,') / 1GB, 5)
            }
            Get-MailboxStatistics -identity ($Mailbox.PrimarySmtpAddress).ToString() | Select-Object @(
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


