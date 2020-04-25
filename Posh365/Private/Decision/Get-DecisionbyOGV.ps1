function Get-DecisionbyOGV {
    [CmdletBinding()]
    param (    )
    $OGVDecision = @{
        Title      = 'Do You Want To Continue Or Quit?'
        OutputMode = 'Single'
    }
    $Decision = 'Yes, I want to continue', 'Quit' | Out-GridView @OGVDecision
    if ($Decision -ne 'Yes, I want to continue') {
        return
    }
}
