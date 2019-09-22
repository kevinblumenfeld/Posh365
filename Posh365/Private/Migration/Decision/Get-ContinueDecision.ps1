function Get-ContinueDecision {
    [CmdletBinding()]
    param (

    )
    end {
        $OGVDecision = @{
            Title      = 'Do You Want To Continue Or Quit?'
            OutputMode = 'Single'
        }
        $Decision = 'Yes, I want to continue', 'Quit' | Out-GridView @OGVDecision
        if ($Decision -eq 'Yes, I want to continue') {
            $UserChoice = $true
        }
        else {
            $UserChoice = $false
        }
        $UserChoice
    }
}
