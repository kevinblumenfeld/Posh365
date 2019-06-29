function Import-MailboxSyncNotCompleted {

    [CmdletBinding()]
    param (

    )
    end {
        $NotCompleted = Get-MailboxSync -NotCompleted | Sort-Object @(
            @{
                Expression = "BatchName"
                Descending = $true
            }
            @{
                Expression = "DisplayName"
                Descending = $false
            }
        )
        $UserChoice = Get-UserDecision -DecisionObject $NotCompleted
        $UserChoice
    }
}

