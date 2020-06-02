function Get-CloudDataRegionalSettings {
    <#
    .SYNOPSIS
    Export all Mailboxes Regional Configuration to a PSCustomObject

    .DESCRIPTION
    Export all Mailboxes Regional Configuration to a PSCustomObject.  Can then be exported to CSV etc.

    .EXAMPLE
    Get-CloudDataRegionalSettings | Export-Csv .\RegionalSettings.csv -notypeinformation

    .NOTES
    Results can be used with Set-CloudDataRegionalSettings during a migration.
    #>

    [CmdletBinding()]
    param (

    )

    $MailboxList = Get-EXOMailbox -Properties ExchangeGuid
    foreach ($Mailbox in $MailboxList) {
        try {
            $Config = Get-MailboxRegionalConfiguration -Identity $Mailbox.ExchangeGuid.ToString() -ErrorAction Stop
            [PSCustomObject]@{
                DisplayName        = $Mailbox.DisplayName
                PrimarySmtpAddress = $Mailbox.PrimarySmtpAddress
                ExchangeGuid       = $Mailbox.ExchangeGuid
                Language           = $Config.Language
                TimeZone           = $Config.TimeZone
                DateFormat         = $Config.DateFormat
                TimeFormat         = $Config.TimeFormat
                Log                = 'SUCCESS'
            }
        }
        catch {
            [PSCustomObject]@{
                DisplayName        = $Mailbox.DisplayName
                PrimarySmtpAddress = $Mailbox.PrimarySmtpAddress
                ExchangeGuid       = $Mailbox.ExchangeGuid
                Language           = ''
                TimeZone           = ''
                DateFormat         = ''
                TimeFormat         = ''
                Log                = $_.Exception.Message
            }
        }
    }
}
