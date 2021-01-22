Function Invoke-ResumeMailboxMove {
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [switch]
        $DontAutoComplete,

        [Parameter()]
        $UserChoice

    )
    if ( -not $UserChoice ) {
        $UserChoice = Import-MailboxMoveDecision -NotCompleted
    }

    if ($UserChoice -ne 'Quit' ) {
        $ResumeSplat = @{
            Confirm     = $false
            ErrorAction = 'Stop'
        }
        if ($DontAutoComplete) {
            $ResumeSplat.Add('SuspendWhenReadyToComplete', $True)
        }
        foreach ($User in $UserChoice) {
            try {
                Resume-MoveRequest -Identity $User.ExchangeGuid @ResumeSplat
                [PSCustomObject]@{
                    DisplayName  = $User.DisplayName
                    ExchangeGuid = $User.ExchangeGuid
                    Action       = 'RESUME'
                    Result       = 'Success'
                    Message      = ''
                }
            }
            catch {
                [PSCustomObject]@{
                    DisplayName  = $User.DisplayName
                    ExchangeGuid = $User.ExchangeGuid
                    Action       = 'RESUME'
                    Result       = 'Failed'
                    Message      = $_.Exception.Message
                }
            }
        }
    }

}
