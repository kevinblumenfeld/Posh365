Function Invoke-SetMailboxMove {
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [switch]
        $SuspendWhenReadyToComplete,

        [Parameter()]
        [int]
        $LargeItemLimit,

        [Parameter()]
        [int]
        $BadItemLimit
    )

    $UserChoice = Import-MailboxMoveDecision -NotCompleted
    if ($UserChoice -ne 'Quit' ) {
        $SetSplat = @{
            AcceptLargeDataLoss = $true
            Confirm             = $false
            warningaction       = 'silentlycontinue'
            ErrorAction         = 'Stop'
        }
        if ($LargeItemLimit) {
            $SetSplat.Add('LargeItemLimit', $LargeItemLimit)
        }
        if ($BadItemLimit) {
            $SetSplat.Add('BadItemLimit', $BadItemLimit)
        }
        if ($SuspendWhenReadyToComplete) {
            $SetSplat.Add('SuspendWhenReadyToComplete', $true)
        }
        foreach ($User in $UserChoice) {
            try {
                Set-MoveRequest -Identity $User.Guid @SetSplat
                [PSCustomObject]@{
                    DisplayName                = $User.DisplayName
                    Result                     = 'SUCCESS'
                    SuspendWhenReadyToComplete = $SetSplat.SuspendWhenReadyToComplete
                    LargeItemLimit             = $SetSplat.LargeItemLimit
                    BadItemLimit               = $SetSplat.BadItemLimit
                    AcceptLargeDataLoss        = 'TRUE'
                    Log                        = 'SUCCESS'
                    Action                     = 'SET'
                }
            }
            catch {
                [PSCustomObject]@{
                    DisplayName                = $User.DisplayName
                    Result                     = 'FAILED'
                    SuspendWhenReadyToComplete = $SetSplat.SuspendWhenReadyToComplete
                    LargeItemLimit             = $SetSplat.LargeItemLimit
                    BadItemLimit               = $SetSplat.BadItemLimit
                    AcceptLargeDataLoss        = 'TRUE'
                    Log                        = $_.Exception.Message
                    Action                     = 'SET'
                }
            }
        }
    }
}
