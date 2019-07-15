function Get-UserDecision {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $DecisionObject,

        [Parameter()]
        [switch]
        $NoBatch,

        [Parameter()]
        [switch]
        $NoConfirmation
    )
    end {

        if (-not $NoBatch) {
            $OGVBatch = @{
                Title      = 'Choose Batch(es)'
                OutputMode = 'Multiple'
            }
            $BatchChoice = $DecisionObject | Select-Object -ExpandProperty BatchName -Unique | Sort-Object | Out-GridView @OGVBatch
        }
        if ($NoBatch) {
            $OGVUser = @{
                Title      = 'Choose User(s)'
                OutputMode = 'Multiple'
            }
            $UserChoice = $DecisionObject | Out-GridView @OGVUser
        }
        else {
            $OGVUser = @{
                Title      = 'Choose User(s)'
                OutputMode = 'Multiple'
            }
            $UserChoice = $DecisionObject | Where-Object { $_.BatchName -in $BatchChoice } | Out-GridView @OGVUser
        }
        if (-not $NoConfirmation) {
            $OGVDecision = @{
                Title      = 'Do You Want To Continue Or Quit?'
                OutputMode = 'Single'
            }
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
        else {
            $UserChoice
        }
    }
}
