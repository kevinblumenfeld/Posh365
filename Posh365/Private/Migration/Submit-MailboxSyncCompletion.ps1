function Submit-MailboxSyncCompletion {

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
            $Param = @{
                Identity                   = $User.Guid
                BatchName                  = $User.BatchName
                SuspendWhenReadyToComplete = $False
                Confirm                    = $False
                CompleteAfter              = $When
            }
            [PSCustomObject]@{
                DisplayName   = $User.DisplayName
                CompleteAfter = $When
                Action        = "SET"
            }
            Set-MoveRequest @Param
            [PSCustomObject]@{
                DisplayName   = $User.DisplayName
                CompleteAfter = "N/A"
                Action        = "RESUME"
            }
            Resume-MoveRequest $User.Guid
        }
    }
}
