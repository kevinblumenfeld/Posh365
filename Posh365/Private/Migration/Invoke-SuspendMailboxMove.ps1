Function Invoke-SuspendMailboxMove {
    [CmdletBinding()]
    param
    (
    )
    end {
        $UserChoice = Import-MailboxMoveDecision -NotCompleted
        if ($UserChoice -ne 'Quit' ) {
            $SuspendSplat = @{
                Confirm     = $false
                ErrorAction = 'Stop'
            }
            foreach ($User in $UserChoice) {
                try {
                    Suspend-MoveRequest -Identity $User.Guid @SuspendSplat
                    [PSCustomObject]@{
                        DisplayName = $User.DisplayName
                        Action      = "SUSPEND"
                        Result      = "Success"
                        Message     = ""
                    }
                }
                catch {
                    [PSCustomObject]@{
                        DisplayName = $User.DisplayName
                        Action      = "SUSPEND"
                        Result      = "Failed"
                        Message     = $_.Exception.Message
                    }
                }
            }
        }
    }
}
