function Set-CloudDataRegionalSettings {
    <#
    .SYNOPSIS
    Imports all Mailboxes Regional Configuration from CSV created by Get-CloudDataRegionalSettings

    .DESCRIPTION
    Imports all Mailboxes Regional Configuration from CSV created by Get-CloudDataRegionalSettings

    Results are exported as PSCustomObject which can be exported to CSV etc.

    .PARAMETER CSVFilePath
    Path to the CSVFile previously exported by Get-CloudDataRegionalSettings

    .EXAMPLE
    Set-CloudDataRegionalSettings -CSVFilePath .\RegionalSettings.csv | Export-Csv .\SetRegionalSettings_Results.csv -Append -notypeinformation

    .NOTES

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $CSVFilePath
    )

    if (Test-Path $CSVFilePath) {
        $MailboxList = Import-Csv $CSVFilePath | Where-Object { $_.Language -and $_.DateFormat }
    }
    else {
        Write-Warning "Path, $CSVFilePath not found. Please try again with the CSV's proper path"
        return
    }
    foreach ($Mailbox in $MailboxList) {
        try {
            Set-MailboxRegionalConfiguration -Identity $Mailbox.ExchangeGuid -Language $Mailbox.Language -TimeZone $Mailbox.TimeZone -ErrorAction Stop
            $NewConfig = Get-MailboxRegionalConfiguration -Identity $Mailbox.ExchangeGuid
            [PSCustomObject]@{
                DisplayName        = $Mailbox.DisplayName
                PrimarySmtpAddress = $Mailbox.PrimarySmtpAddress
                ExchangeGuid       = $Mailbox.ExchangeGuid
                NewLanguage        = $NewConfig.Language
                NewTimeZone        = $NewConfig.TimeZone
                SourceLanguage     = $Mailbox.Language
                SourceTimeZone     = $Mailbox.TimeZone
                DateFormat         = $Mailbox.DateFormat
                TimeFormat         = $Mailbox.TimeFormat
                Log                = 'SUCCESS'
            }
        }
        catch {
            [PSCustomObject]@{
                DisplayName        = $Mailbox.DisplayName
                PrimarySmtpAddress = $Mailbox.PrimarySmtpAddress
                ExchangeGuid       = $Mailbox.ExchangeGuid
                NewLanguage        = 'FAILED'
                NewTimeZone        = 'FAILED'
                SourceLanguage     = $Mailbox.Language
                SourceTimeZone     = $Mailbox.TimeZone
                DateFormat         = $Mailbox.DateFormat
                TimeFormat         = $Mailbox.TimeFormat
                Log                = $_.Exception.Message
            }
        }
    }
}
