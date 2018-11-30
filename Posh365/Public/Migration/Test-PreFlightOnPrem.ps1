function Test-PreFlightOnPrem {
    param (
        [Parameter(Mandatory = $true)]
        [String] $CsvFileName,

        [Parameter(Mandatory = $true)]
        [string] $Tenant
    )

    if ($Tenant -match 'onmicrosoft') {
        $Tenant = $Tenant.Split(".")[0]
    }

    $Import = Import-Csv $CsvFileName

    foreach ($CurImport in $Import) {
        $WhyFailed = ""
        $UPN = $CurImport.Check
        $CurImport.Check = $UPN
        $CurImport.BatchName = $CurImport.BatchName
        
        if ($CurImport.PreFlightComplete -ne "TRUE") {

            try {
                $Mailbox = Get-Mailbox -Identity $UPN -ErrorAction Stop

                $CurImport.RecipientType = $Mailbox.RecipientTypeDetails
                $CurImport.SamAccountName = $Mailbox.SamAccountName
                $CurImport.ForwardingSmtpAddress = $Mailbox.ForwardingSmtpAddress
                $CurImport.DeliverToMailboxAndForward = $Mailbox.DeliverToMailboxAndForward
            }
            catch {
                $WhyFailed = (($_.Exception.Message) -replace ",", ";") -replace "\n", "|**|"

                Write-Verbose "Error executing: Get-Mailbox $UPN"
                Write-Verbose $WhyFailed
                $CurImport.ErrorOnPrem = $WhyFailed

                continue
            }
            if ($Mailbox.ForwardingAddress -ne $null) {
                $Forward = Get-Recipient $Mailbox.ForwardingAddress

                $CurImport.ForwardingAddress = $Forward.PrimarySmtpAddress
            }
            else {
                $CurImport.ForwardingAddress = "Not Found"
            }
            try {
                $CasMailbox = Get-CASMailbox -Identity $UPN -ErrorAction Stop 
                if ($CasMailbox.ActiveSyncEnabled -eq $true) {
                    $CurImport.ActiveSyncEnabled = "TRUE"
                }
                else {
                    $CurImport.ActiveSyncEnabled = "FALSE"
                }
            }
            catch {
                $WhyFailedCAS = (($_.Exception.Message) -replace ",", ";") -replace "\n", "|**|"
                $WhyFailed += $WhyFailedCAS
                Write-Verbose "Error executing: Get-CASMailbox $UPN"
                Write-Verbose $WhyFailedCAS
            }
            if ($WhyFailed -and $WhyFailedCAS) {
                $CurImport.ErrorOnPrem = $WhyFailed
            }
            else {
                $CurImport.ErrorOnPrem = ""
            }
        }
        $Import | Export-Csv $CsvFileName -NoTypeInformation -Encoding UTF8
    }
}