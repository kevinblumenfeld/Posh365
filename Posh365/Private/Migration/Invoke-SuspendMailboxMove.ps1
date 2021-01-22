Function Invoke-SuspendMailboxMove {
    [CmdletBinding()]
    param
    (

        [Parameter()]
        $UserChoice
    )
    if ( -not $UserChoice ) {
        $UserChoice = Import-MailboxMoveDecision -NotCompleted
    }
    if ($UserChoice -ne 'Quit' ) {
        $SuspendSplat = @{
            Confirm     = $false
            ErrorAction = 'Stop'
        }
        foreach ($User in $UserChoice) {
            try {
                Suspend-MoveRequest -Identity $User.ExchangeGuid @SuspendSplat
                [PSCustomObject]@{
                    DisplayName  = $User.DisplayName
                    ExchangeGuid = $User.ExchangeGuid
                    Action       = 'SUSPEND'
                    Result       = 'Success'
                    Message      = ''
                }
            }
            catch {
                [PSCustomObject]@{
                    DisplayName  = $User.DisplayName
                    ExchangeGuid = $User.ExchangeGuid
                    Action       = 'SUSPEND'
                    Result       = 'Failed'
                    Message      = $_.Exception.Message
                }
            }
        }
    }

}
