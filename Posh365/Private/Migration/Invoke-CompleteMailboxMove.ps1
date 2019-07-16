function Invoke-CompleteMailboxMove {

    param (

        [Parameter(ValueFromPipeline, Mandatory)]
        [ValidateNotNullOrEmpty()]
        $UserList,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        $CompleteAfter

    )
    begin {

        if ($CompleteAfter) {
            $When = $CompleteAfter
        }
        else {
            $When = (Get-Date).AddDays(-1)
        }
    }
    process {
        foreach ($User in $UserList) {
            try {

                $Param = @{
                    Identity                   = $User.Guid
                    BatchName                  = $User.BatchName
                    SuspendWhenReadyToComplete = $False
                    Confirm                    = $False
                    CompleteAfter              = $When
                    ErrorAction                = 'Stop'
                }

                Set-MoveRequest @Param
                [PSCustomObject]@{
                    DisplayName   = $User.DisplayName
                    CompleteAfter = $When
                    Action        = "SET"
                    Result        = "Success"
                    Message       = ""
                }
            }
            catch {
                [PSCustomObject]@{
                    DisplayName   = $User.DisplayName
                    CompleteAfter = $When
                    Action        = "SET"
                    Result        = "Failed"
                    Message       = $_.Exception.Message
                }
            }
            try {
                Resume-MoveRequest $User.Guid
                [PSCustomObject]@{
                    DisplayName   = $User.DisplayName
                    CompleteAfter = ""
                    Action        = "RESUME"
                    Result        = "Success"
                    Message       = ""
                }
            }
            catch {
                [PSCustomObject]@{
                    DisplayName   = $User.DisplayName
                    CompleteAfter = ""
                    Action        = "RESUME"
                    Result        = "Failed"
                    Message       = $_.Exception.Message
                }
            }
        }
    }
}
