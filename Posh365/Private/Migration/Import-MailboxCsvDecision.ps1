function Import-MailboxCsvDecision {

    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $MailboxCsv
    )
    end {
        $Mailbox = Import-Csv -Path $MailboxCSV
        $UserChoice = Get-UserDecision -DecisionObject $Mailbox
        $UserChoice
    }
}

