function Import-MailboxCsvDecision {

    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $MailboxCsv,

        [Parameter()]
        [switch]
        $NoBatch
    )
    end {
        $UserChoiceSplat = @{
            DecisionObject = Import-Csv -Path $MailboxCSV
            NoBatch        = $NoBatch
        }

        $UserChoice = Get-UserDecision @UserChoiceSplat
        $UserChoice
    }
}

