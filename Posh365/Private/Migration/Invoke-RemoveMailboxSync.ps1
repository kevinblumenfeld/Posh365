Function Invoke-RemoveMailboxSync {
    [CmdletBinding()]
    param
    (

    )
    end {
        $UserChoice = Import-MailboxSyncDecision
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
