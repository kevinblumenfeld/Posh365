Function Invoke-RemoveMailboxMove {
    [CmdletBinding()]
    param (
        [Parameter()]
        $RandRObject
    )
    end {
        if ($RandRObject) {
            $UserChoice = $RandRObject | Select-Object @(
                'DisplayName'
                @{
                    Name       = 'Guid'
                    Expression = { $_.ExchangeGuid.toString() }
                }
            )
        }
        else {
            $UserChoice = Import-MailboxMoveDecision
        }

        if ($UserChoice -ne 'Quit' ) {
            foreach ($User in $UserChoice) {
                try {
                    Remove-MoveRequest -Identity $User.Guid -Confirm:$false -ErrorAction Stop
                    [PSCustomObject]@{
                        DisplayName = $User.DisplayName
                        Result      = 'SUCCESS'
                        Log         = 'SUCCESS'
                        Action      = 'REMOVE'
                    }
                }
                catch {
                    [PSCustomObject]@{
                        DisplayName = $User.DisplayName
                        Result      = 'FAILED'
                        Log         = $_.Exception.Message
                        Action      = 'REMOVE'
                    }
                }
            }
        }
    }
}
