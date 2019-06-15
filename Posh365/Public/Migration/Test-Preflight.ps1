function Test-Preflight {
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        $MailboxCSV,

        [Parameter()]
        [switch]
        $UpnMatch
    )
    end {

        $Mailbox = Import-Csv -Path $MailboxCSV

        $OGVBatch = @{
            Title      = 'Choose Batch(es)'
            OutputMode = 'Multiple'
        }

        $OGVUser = @{
            Title      = 'Choose User(s)'
            OutputMode = 'Multiple'
        }

        $BatchChoice = $Mailbox | Select-Object -ExpandProperty Batch -Unique | Out-GridView @OGVBatch
        $UserChoice = $Mailbox | Where-Object { $_.Batch -in $BatchChoice } | Out-GridView @OGVUser

        if ($UpnMatch) {
            $UserChoice | Test-UpnMatch
        }
    }
}

