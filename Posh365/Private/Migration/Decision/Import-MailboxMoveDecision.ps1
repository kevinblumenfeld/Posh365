function Import-MailboxMoveDecision {

    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $NotCompleted
    )
    end {
        if ($NotCompleted) {
            $DecisionObject = Invoke-GetMailboxMove -NotCompleted | Sort-Object @(
                @{
                    Expression = "BatchName"
                    Descending = $true
                }
                @{
                    Expression = "DisplayName"
                    Descending = $false
                }
            )
            $UserChoice = Get-UserDecision -DecisionObject $DecisionObject
            $UserChoice
        }
        else {
            $DecisionObject = Invoke-GetMailboxMove | Sort-Object @(
                @{
                    Expression = "BatchName"
                    Descending = $true
                }
                @{
                    Expression = "DisplayName"
                    Descending = $false
                }
            )
            $UserChoice = Get-UserDecision -DecisionObject $DecisionObject
            $UserChoice
        }
    }
}

