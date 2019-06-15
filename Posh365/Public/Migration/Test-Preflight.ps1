function Test-Preflight {
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        $MailboxCSV,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [switch]
        $UpnMatch
    )
    end {

        $Mailbox = Import-Csv -Path $MailboxCSV

        $BatchChoice = $Mailbox | Select-Object -ExpandProperty Batch -Unique | Out-GridView @OGVBatch
        $UserChoice = $Mailbox | Where-Object { $_.Batch -in $BatchChoice } | Out-GridView @OGVUser

        if ($UpnMatch) {
            $UserChoice | Test-UpnMatch
        }
    }
}

