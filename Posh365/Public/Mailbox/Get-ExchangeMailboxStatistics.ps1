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
    Ultimately the Mailbox Guid is used to find the statistics using the new EXO v.2 cmdlets
    #>

    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipeline = $true,
            Mandatory = $true)]
        $MailboxList
    )
    begin {

    }
    process {
        foreach ($Mailbox in $MailboxList) {
            if ($Mailbox.ArchiveDatabase) {
                $ArchiveGB = Get-EXOMailboxStatistics -ExchangeGuid ($Mailbox.Guid).ToString() -Archive -Properties LastLogonTime -Verbose:$false | Select-Object @(
                    @{
                        Name       = 'ArchiveStat'
                        Expression = { [Math]::Round([Double]($_.TotalItemSize -replace '^.*\(| .+$|,') / 1GB, 4) }
                    }
                )
            }
            Get-EXOMailboxStatistics -ExchangeGuid ($Mailbox.Guid).ToString() -WarningAction SilentlyContinue -Properties LastLogonTime -Verbose:$false | Select-Object @(
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
                    Expression = { $ArchiveGB.ArchiveStat }
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
                        [Math]::Round([Double]($_.TotalItemSize -replace '^.*\(| .+$|,') / 1GB, 4) + $ArchiveGB.ArchiveStat
                    }
                }
                'LastLogonTime'
                'ItemCount'
            )
        }
    }
    end {

    }
}
