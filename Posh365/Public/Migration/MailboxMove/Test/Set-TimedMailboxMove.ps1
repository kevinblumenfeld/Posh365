function Set-TimedMailboxMove {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $Tenant,

        [Parameter()]
        [switch]
        $GCCHigh,

        [Parameter()]
        [string[]]
        $Batch,

        [Parameter()]
        [int]
        $CompleteAfterDays = 365,

        [Parameter()]
        [int]
        $IncrementalSyncHours = 24,

        [Parameter()]
        [switch]
        $Set,

        [Parameter()]
        [switch]
        $Resume,

        [Parameter()]
        [switch]
        $Suspend,

        [Parameter()]
        [int]
        $BadItemLimit,

        [Parameter()]
        [int]
        $LargeItemLimit,

        [Parameter()]
        [switch]
        $FailedOnly
    )

    Get-PSSession | Remove-PSSession

    Connect-Cloud -Tenant $Tenant -EXOCBA -GCCHigh:$GCCHigh -NoTranscript

    if ($FailedOnly) {
        $Incomplete = Get-MoveRequest -ResultSize Unlimited | Where-Object {
            $_.Status -eq "Failed" -and $_.BatchName -match ($Batch -join '|')
        }
    }
    else {
        $Incomplete = Get-MoveRequest -ResultSize Unlimited | Where-Object {
            $_.Status -notlike "*Completed*" -and $_.BatchName -match ($Batch -join '|')
        }
    }

    if ($Set -or $Resume) {

        :CantSet foreach ($In in $Incomplete) {

            try {

                $SetSplat = @{
                    Identity                   = $In.ExchangeGuid
                    CompleteAfter              = (Get-Date).AddDays($CompleteAfterDays)
                    IncrementalSyncInterval    = [timespan]::new($IncrementalSyncHours, 00, 00)
                    SuspendWhenReadyToComplete = $false
                    ErrorAction                = 'Stop'
                }

                if ($BadItemLimit) {
                    $SetSplat['BadItemLimit'] = $BadItemLimit
                }
                if ($LargeItemLimit) {
                    $SetSplat['LargeItemLimit'] = $LargeItemLimit
                }
                if ($LargeItemLimit -or $BadItemLimit) {
                    $SetSplat['WarningAction'] = 'Ignore'
                }

                Set-MoveRequest @SetSplat

                [PSCustomObject]@{
                    DisplayName  = $In.DisplayName
                    BatchName    = $In.BatchName
                    ExchangeGuid = $In.ExchangeGuid
                    Action       = 'SET'
                    Result       = 'SUCCESS'
                    Log          = 'SUCCESS'
                }
            }
            catch {
                [PSCustomObject]@{
                    DisplayName  = $In.DisplayName
                    BatchName    = $In.BatchName
                    ExchangeGuid = $In.ExchangeGuid
                    Action       = 'SET'
                    Result       = 'FAILED'
                    Log          = $_.Exception.Message
                }
                continue CantSet
            }
            if ($Resume) {

                try {

                    Resume-MoveRequest -Identity $In.ExchangeGuid -Confirm:$false -ErrorAction Stop

                    [PSCustomObject]@{
                        DisplayName  = $In.DisplayName
                        BatchName    = $In.BatchName
                        ExchangeGuid = $In.ExchangeGuid
                        Action       = 'RESUME'
                        Result       = 'SUCCESS'
                        Log          = 'SUCCESS'
                    }
                }
                catch {
                    [PSCustomObject]@{
                        DisplayName  = $In.DisplayName
                        BatchName    = $In.BatchName
                        ExchangeGuid = $In.ExchangeGuid
                        Action       = 'RESUME'
                        Result       = 'FAILED'
                        Log          = $_.Exception.Message
                    }
                }
            }
        }
    }
    if ($Suspend) {

        foreach ($In in $Incomplete) {

            try {

                Suspend-MoveRequest -Identity $In.ExchangeGuid -Confirm:$false -ErrorAction Stop

                [PSCustomObject]@{
                    DisplayName  = $In.DisplayName
                    BatchName    = $In.BatchName
                    ExchangeGuid = $In.ExchangeGuid
                    Action       = 'SUSPEND'
                    Result       = 'SUCCESS'
                    Log          = 'SUCCESS'
                }
            }
            catch {
                [PSCustomObject]@{
                    DisplayName  = $In.DisplayName
                    BatchName    = $In.BatchName
                    ExchangeGuid = $In.ExchangeGuid
                    Action       = 'SUSPEND'
                    Result       = 'FAILED'
                    Log          = $_.Exception.Message
                }
            }
        }
    }
}
