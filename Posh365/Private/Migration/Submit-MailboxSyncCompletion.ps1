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
            $when = $CompleteAfter
        }
        else {
            $when = (Get-Date).AddDays(-1)
        }
    }
    process {
        foreach ($User in $UserList) {
            $Param = @{
                Identity                   = $User.Guid
                BatchName                  = $User.BatchName
                SuspendWhenReadyToComplete = $False
                Confirm                    = $False
                CompleteAfter              = $when
            }
            Set-MoveRequest @Param
            Resume-MoveRequest $User.Guid
        }
    }
}
