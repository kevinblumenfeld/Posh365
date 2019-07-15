function Import-MailboxMoveDecision {

    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $NotCompleted
    )
    end {
        if ($NotCompleted) {
            $DecisionObject = Get-MailboxMove -NotCompleted | Sort-Object @(
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
            $DecisionObject = Get-MailboxMove | Sort-Object @(
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

