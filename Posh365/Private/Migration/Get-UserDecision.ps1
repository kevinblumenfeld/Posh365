function Get-UserDecision {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $DecisionObject

    )
    end {

        $OGVBatch = @{
            Title      = 'Choose Batch(es)'
            OutputMode = 'Multiple'
        }

        $OGVUser = @{
            Title      = 'Choose User(s)'
            OutputMode = 'Multiple'
        }

        $OGVDecision = @{
            Title      = 'Do You Want To Continue Or Quit?'
            OutputMode = 'Single'
        }

        $BatchChoice = $DecisionObject | Select-Object -ExpandProperty BatchName -Unique | Out-GridView @OGVBatch
        $UserChoice = $DecisionObject | Where-Object { $_.BatchName -in $BatchChoice } | Out-GridView @OGVUser

        if ($UserChoice) {
            $Decision = 'Yes, I want to continue', 'Quit' | Out-GridView @OGVDecision
        }

        if ($Decision -eq 'Yes, I want to continue') {
            $UserChoice
        }
        else {
            $UserChoice = 'Quit'
            $UserChoice
        }
    }
}
