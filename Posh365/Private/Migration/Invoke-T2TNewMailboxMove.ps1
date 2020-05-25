function Invoke-T2TNewMailboxMove {
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [ValidateNotNullOrEmpty()]
        $UserList,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $RemoteHost,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Tenant,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]
        $BadItemLimit,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]
        $LargeItemLimit,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]
        $IncrementalSyncIntervalHours
    )
    begin {
       $SyncTime =  [timespan]::new($IncrementalSyncIntervalHours, 00, 00)
    }
    process {
        foreach ($User in $UserList) {
            $Param = @{
                BatchName               = $User.BatchName
                Identity                = $User.ExchangeGuid
                Outbound                = $true
                RemoteTenant            = $RemoteHost
                TargetDeliveryDomain    = $Tenant
                BadItemLimit            = $BadItemLimit
                LargeItemLimit          = $LargeItemLimit
                CompleteAfter           = (Get-Date).AddMonths(12)
                IncrementalSyncInterval = $SyncTime
                AcceptLargeDataLoss     = $true
            }
            # New-MoveRequest –OutBound -Identity <mailboxguid> -RemoteTenant "Contoso.onmicrosoft.com" -TargetDeliveryDomain Contoso.onmicrosoft.com -BadItemLimit 50 -CompleteAfter (Get-Date).AddMonths(12) -IncrementalSyncInterval '24:00:00'

            try {
                $Result = New-MoveRequest @Param -WarningAction SilentlyContinue -ErrorAction Stop
                [PSCustomObject]@{
                    'DisplayName'       = $User.DisplayName
                    'UserPrincipalName' = $User.UserPrincipalName
                    'Result'            = 'SUCCESS'
                    'MailboxSize'       = [regex]::Matches("$($Result.TotalMailboxSize)", "^[^(]*").value
                    'ArchiveSize'       = [regex]::Matches("$($Result.TotalArchiveSize)", "^[^(]*").value
                    'Log'               = $Result.StatusDetail
                    'Action'            = 'NEW'
                }
            }
            catch {
                [PSCustomObject]@{
                    'DisplayName'       = $User.DisplayName
                    'UserPrincipalName' = $User.UserPrincipalName
                    'Result'            = 'FAILED'
                    'MailboxSize'       = ''
                    'ArchiveSize'       = ''
                    'Log'               = $_.Exception.Message
                    'Action'            = 'NEW'
                }
            }
        }
    }
}
