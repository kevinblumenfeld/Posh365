function Select-SyncRemoteRoutingAddress {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $RMChoice
    )

    $i = 0
    $Total = @($RMChoice).count
    foreach ($RMItem in $RMChoice) {
        $i++
        try {
            $RemoteMailboxLookup = $null
            $RemoteMailboxLookup = Get-RemoteMailbox -filter "ExchangeGuid -eq '$($RMItem.ExchangeGuid)'"
            if ($RemoteMailboxLookup) {
                $RemoteMailboxLookup | Set-RemoteMailbox -RemoteRoutingAddress $RMItem.RequestedRRA -ErrorAction Stop
                $PostRMSet = $null
                $PostRMSet = Get-RemoteMailbox -filter "ExchangeGuid -eq '$($RMItem.ExchangeGuid)'"
                [PSCustomObject]@{
                    Num                        = '[{0} of {1}]' -f $i, $Total
                    DisplayName                = $PostRMSet.DisplayName
                    Log                        = 'SUCCESS'
                    RequestedRRA               = $RMItem.RequestedRRA
                    PreviousRRA                = $RMItem.CurrentRRA
                    CurrentRRA                 = $PostRMSet.RemoteRoutingAddress
                    RRATaskSuccess             = $RMItem.RequestedRRA -eq ($PostRMSet.RemoteRoutingAddress).split(':')[1]
                    PrimaryUnchanged           = $RemoteMailboxHash[$RMItem.ExchangeGuid]['PrimarySmtpAddress'] -eq $PostRMSet.PrimarySmtpAddress
                    EmailsUnchanged            = @($PostRMSet.EmailAddresses) -ne '' -join '|' -eq $RemoteMailboxHash[$RMItem.ExchangeGuid]['EmailAddresses']
                    CurrentPrimarySmtpAddress  = $PostRMSet.PrimarySmtpAddress
                    PreviousPrimarySmtpAddress = $RMItem.PrimarySmtpAddress
                    CurrentEmailAddresses      = @($PostRMSet.EmailAddresses) -ne '' -join '|'
                    PreviousEmailAddresses     = $RMItem.EmailAddresses
                }
            }
        }
        catch {
            [PSCustomObject]@{
                Num                        = '[{0} of {1}]' -f $i, $Total
                DisplayName                = $PostRMSet.DisplayName
                Log                        = $_.Exception.Message
                RequestedRRA               = $RMItem.RequestedRRA
                PreviousRRA                = $RMItem.CurrentRRA
                CurrentRRA                 = 'FAILED'
                RRATaskSuccess             = 'FAILED'
                PrimaryUnchanged           = 'FAILED'
                EmailsUnchanged            = 'FAILED'
                CurrentPrimarySmtpAddress  = 'FAILED'
                PreviousPrimarySmtpAddress = 'FAILED'
                CurrentEmailAddresses      = 'FAILED'
                PreviousEmailAddresses     = $RemoteMailboxHash[$RMItem.ExchangeGuid]['EmailAddresses']
            }
        }
    }
}
