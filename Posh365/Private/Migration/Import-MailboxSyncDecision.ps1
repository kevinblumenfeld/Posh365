function Import-MailboxSyncDecision {

    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $NotCompleted
    )
    end {
        if ($NotCompleted) {
            $DecisionObject = Get-MailboxSync -NotCompleted | Sort-Object @(
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
            $DecisionObject = Get-MailboxSync | Sort-Object @(
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

