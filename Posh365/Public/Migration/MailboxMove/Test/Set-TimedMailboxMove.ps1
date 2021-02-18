function Set-TimedMailboxMove {

    [CmdletBinding(DefaultParameterSetName = 'PlaceHolder')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'All')]
        [String]
        $Tenant,

        [Parameter(ParameterSetName = 'All')]
        [switch]
        $GCCHigh,

        [Parameter(Mandatory, ParameterSetName = 'Resume')]
        [Parameter(ParameterSetName = 'All')]
        [switch]
        $Resume,

        [Parameter(Mandatory, ParameterSetName = 'Suspend')]
        [Parameter(ParameterSetName = 'All')]
        [switch]
        $Suspend
    )

    Get-PSSession | Remove-PSSession
    Connect-Cloud -Tenant $Tenant -EXOCBA -GCCHigh:$GCCHigh -NoTranscript
    if ($Suspend) {
        $SuspendList = Get-MoveRequest -ResultSize Unlimited -MoveStatus InProgress
        foreach ($Sus in $SuspendList) {
            try {
                Suspend-MoveRequest -Identity $Sus.ExchangeGuid -Confirm:$false
                [PSCustomObject]@{
                    DisplayName  = $Sus.DisplayName
                    BatchName    = $Sus.BatchName
                    ExchangeGuid = $Sus.ExchangeGuid
                    Action       = 'SUSPEND'
                    Result       = 'SUCCESS'
                    Log          = 'SUCCESS'
                }
            }
            catch {
                [PSCustomObject]@{
                    DisplayName  = $Sus.DisplayName
                    BatchName    = $Sus.BatchName
                    ExchangeGuid = $Sus.ExchangeGuid
                    Action       = 'SUSPEND'
                    Result       = 'FAILED'
                    Log          = $_.Exception.Message
                }
            }
        }
    }
    if ($Resume) {
        $ResumeList = Get-MoveRequest -ResultSize Unlimited | Where-Object { $_.Status -match 'Failed|Suspended|AutoSuspended' }
        foreach ($Res in $ResumeList) {
            try {
                Resume-MoveRequest -Identity $Res.ExchangeGuid -SuspendWhenReadyToComplete:$true
                [PSCustomObject]@{
                    DisplayName  = $Res.DisplayName
                    BatchName    = $Res.BatchName
                    ExchangeGuid = $Res.ExchangeGuid
                    Action       = 'RESUME'
                    Result       = 'SUCCESS'
                    Log          = 'SUCCESS'
                }
            }
            catch {
                [PSCustomObject]@{
                    DisplayName  = $Res.DisplayName
                    BatchName    = $Res.BatchName
                    ExchangeGuid = $Res.ExchangeGuid
                    Action       = 'RESUME'
                    Result       = 'FAILED'
                    Log          = $_.Exception.Message
                }
            }
        }
    }
}
