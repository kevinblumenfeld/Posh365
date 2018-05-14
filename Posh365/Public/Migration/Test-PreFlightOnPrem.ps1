function Test-PreFlightOnPrem {
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo] $csvFileName
    )

    Write-Host "`r`n"
    Write-Host "Importing CSV from: `"$csvFileName`"" -ErrorAction Stop
    $mailboxes = Import-Csv $csvFileName
    $i = 1
    $count = $mailboxes.count

    foreach ($mailbox in $mailboxes) {
        $upn = $mailbox.MailUser

        $percent = [int](($i / $count) * 100)
        Write-Progress -Activity "Running PreChecks" -Status "Processing $upn ($i of $count)" -PercentComplete $percent

        Write-Host "`nBEGIN CHECKS FOR " -NoNewline
        Write-Host " $upn `n" -ForegroundColor Yellow
        $onPremMailbox = Get-Mailbox -Identity $upn -ErrorAction SilentlyContinue
        $mailbox.RecipientType = $onPremMailbox.RecipientTypeDetails
        $mailbox.SamAccountName = $onPremMailbox.SamAccountName

        Write-Host "`tForwarders: " -NoNewLine
        if ($onPremMailbox.ForwardingAddress -ne $NULL) {
            $forward = Get-Recipient $onPremMailbox.ForwardingAddress
            $mailbox.ForwardingAddress = $forward.PrimarySmtpAddress
            Write-Host "$($forward.PrimarySmtpAddress)" -ForegroundColor Cyan
        }
        else {
            Write-Host "Not Found" -ForegroundColor Green
            $mailbox.ForwardingAddress = "Not Found"
        }

        $casOnPremMailbox = Get-CASMailbox -Identity $upn -ErrorAction SilentlyContinue
        Write-Host "`tActiveSync: " -NoNewLine
        if ($casOnPremMailbox.ActiveSyncenabled -eq $TRUE) {
            $mailbox.ActiveSyncEnabled = "TRUE"
            Write-Host "Enabled" -ForegroundColor Cyan
        }
        else {
            $mailbox.ActiveSyncEnabled = "FALSE"
            Write-Host "Disabled" -ForegroundColor Red
        }
        $i++
    }
    $mailboxes | Export-Csv $csvfile -NoTypeInformation -Encoding UTF8
}
