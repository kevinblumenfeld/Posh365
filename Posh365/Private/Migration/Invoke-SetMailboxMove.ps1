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
        $BadItemLimit,

        [Parameter()]
        [switch]
        $AcceptLargeDataLoss
    )

    $UserChoice = Import-MailboxMoveDecision -NotCompleted
    if ($UserChoice -ne 'Quit' ) {
        $SetSplat = @{
            AcceptLargeDataLoss = $AcceptLargeDataLoss
            Confirm             = $false
            warningaction       = 'silentlycontinue'
            ErrorAction         = 'Stop'
        }
        if ($PSBoundParameters.ContainsKey('LargeItemLimit')) {
            $SetSplat['LargeItemLimit'] = $LargeItemLimit
        }
        if ($PSBoundParameters.ContainsKey('BadItemLimit')) {
            $SetSplat['BadItemLimit'] = $BadItemLimit
        }
        if ($SuspendWhenReadyToComplete) {
            $SetSplat['SuspendWhenReadyToComplete'] = $true
        }
        foreach ($User in $UserChoice) {
            try {
                Set-MoveRequest -Identity $User.Guid @SetSplat
                [PSCustomObject]@{
                    DisplayName                = $User.DisplayName
                    ExchangeGuid               = $User.ExchangeGuid.toString()
                    Result                     = 'SUCCESS'
                    SuspendWhenReadyToComplete = $SetSplat['SuspendWhenReadyToComplete']
                    LargeItemLimit             = $SetSplat['LargeItemLimit']
                    BadItemLimit               = $SetSplat['BadItemLimit']
                    AcceptLargeDataLoss        = 'TRUE'
                    Log                        = 'SUCCESS'
                    Action                     = 'SET'
                }
            }
            catch {
                [PSCustomObject]@{
                    DisplayName                = $User.DisplayName
                    ExchangeGuid               = $User.ExchangeGuid.toString()
                    Result                     = 'FAILED'
                    SuspendWhenReadyToComplete = $SetSplat['SuspendWhenReadyToComplete']
                    LargeItemLimit             = $SetSplat['LargeItemLimit']
                    BadItemLimit               = $SetSplat['BadItemLimit']
                    AcceptLargeDataLoss        = 'TRUE'
                    Log                        = $_.Exception.Message
                    Action                     = 'SET'
                }
            }
        }
    }
}
