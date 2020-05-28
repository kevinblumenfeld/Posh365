function Invoke-SyncRemoteRoutingAddress {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $RemoteMailboxChoice
    )

    $i = 0
    $Total = @($RemoteMailboxChoice).count
    foreach ($RM in $RemoteMailboxChoice) {
        $i++
        try {
            $RemoteMailboxLookup = $null
            $RemoteMailboxLookup = Get-RemoteMailbox -filter "ExchangeGuid -eq '$($RM.ExchangeGuid)'"
            if ($RemoteMailboxLookup) {
                $RemoteMailboxLookup | Set-RemoteMailbox -RemoteRoutingAddress $RM.RequestedRRA -ErrorAction Stop
                $PostRMSet = $null
                $PostRMSet = Get-RemoteMailbox -filter "ExchangeGuid -eq '$($RM.ExchangeGuid)'"
                [PSCustomObject]@{
                    Num                        = '[{0} of {1}]' -f $i, $Total
                    DisplayName                = $PostRMSet.DisplayName
                    Log                        = 'SUCCESS'
                    RequestedRRA               = $RM.RequestedRRA
                    PreviousRRA                = $RM.CurrentRRA
                    CurrentRRA                 = $PostRMSet.RemoteRoutingAddress
                    RRATaskSuccess             = $RM.RequestedRRA -eq ($PostRMSet.RemoteRoutingAddress).split(':')[1]
                    PrimaryUnchanged           = $RemoteMailboxHash[$RM.ExchangeGuid]['PrimarySmtpAddress'] -eq $PostRMSet.PrimarySmtpAddress
                    EmailsUnchanged            = @($PostRMSet.EmailAddresses) -ne '' -join '|' -eq $RemoteMailboxHash[$RM.ExchangeGuid]['EmailAddresses']
                    CurrentPrimarySmtpAddress  = $PostRMSet.PrimarySmtpAddress
                    PreviousPrimarySmtpAddress = $RM.PrimarySmtpAddress
                    CurrentEmailAddresses      = @($PostRMSet.EmailAddresses) -ne '' -join '|'
                    PreviousEmailAddresses     = $RM.EmailAddresses
                }
            }
        }
        catch {
            [PSCustomObject]@{
                Num                        = '[{0} of {1}]' -f $i, $Total
                DisplayName                = $PostRMSet.DisplayName
                Log                        = $_.Exception.Message
                RequestedRRA               = $RM.RequestedRRA
                PreviousRRA                = $RM.CurrentRRA
                CurrentRRA                 = 'FAILED'
                RRATaskSuccess             = 'FAILED'
                PrimaryUnchanged           = 'FAILED'
                EmailsUnchanged            = 'FAILED'
                CurrentPrimarySmtpAddress  = 'FAILED'
                PreviousPrimarySmtpAddress = 'FAILED'
                CurrentEmailAddresses      = 'FAILED'
                PreviousEmailAddresses     = $RemoteMailboxHash[$RM.ExchangeGuid]['EmailAddresses']
            }
        }
    }
}
