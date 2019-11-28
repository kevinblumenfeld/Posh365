Function Get-MailboxMoveOnPremisesMailboxReport {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $ReportPath
    )
    end {
        New-Item -ItemType Directory -Path $ReportPath -ErrorAction SilentlyContinue
        $BatchesFile = Join-Path $ReportPath 'Batches.csv'
        $Select = @(
            'BatchName', 'DisplayName', 'OrganizationalUnit', 'IsMigrated', 'CompleteBatchDate'
            'CompleteBatchTimePT', 'LicenseGroup', 'EnableArchive', 'ConvertToShared'
            'MailboxGB', 'ArchiveGB', 'DeletedGB', 'TotalGB', 'LastLogonTime'
            'ItemCount', 'UserPrincipalName', 'PrimarySmtpAddress'
            'AddressBookPolicy', 'RetentionPolicy', 'AccountDisabled', 'Alias'
            'Database', 'OU', 'Office', 'RecipientTypeDetails', 'UMEnabled'
            'ForwardingAddress', 'ForwardingRecipientType', 'ForwardingSmtpAddress'
            'DeliverToMailboxAndForward'
        )
        Get-MailboxMoveOnPremisesReportHelper | Select-Object $Select | Export-Csv $BatchesFile -NoTypeInformation -Encoding UTF8

        $ExcelSplat = @{
            Path                    = (Join-Path $ReportPath 'Batches.xlsx')
            TableStyle              = 'Medium2'
            FreezeTopRowFirstColumn = $true
            AutoSize                = $true
            BoldTopRow              = $true
            ClearSheet              = $true
            WorksheetName           = 'Batches'
            ErrorAction             = 'stop'
        }
        try {
            $BatchesFile | Where-Object { $_ } | ForEach-Object { Import-Csv $_ | Export-Excel @ExcelSplat }
        }
        catch {
            $_.Exception.Message
        }
    }
}
