function Get-UserDecision {

    param (

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        $MailboxCSV

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

        $OGVDecision = @{
            Title      = 'Migrate Users or Quit?'
            OutputMode = 'Single'
        }

        $BatchChoice = $Mailbox | Select-Object -ExpandProperty Batch -Unique | Out-GridView @OGVBatch
        $UserChoice = $Mailbox | Where-Object { $_.Batch -in $BatchChoice } | Out-GridView @OGVUser

        if ($UserChoice) {
            $Decision = 'Yes, I want to continue', 'Quit' | Out-GridView @OGVDecision
        }

        if ($Decision -eq 'Yes, I want to continue') {
            $UserChoice
        }
    }
}
