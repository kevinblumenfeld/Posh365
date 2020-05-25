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
        $LargeItemLimit
    )
    begin {
        $CredentialPath = "${env:\userprofile}\$Tenant.Migrations.Cred"

        if (Test-Path $CredentialPath) {
            $RemoteCred = Import-Clixml -Path $CredentialPath
        }
        else {
            $RemoteCred = Get-Credential -Message "Enter Credentials for Remote Host DOMAIN\User (On-Premises Migration Endpoint)"
            $RemoteCred | Export-Clixml -Path $CredentialPath
        }
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
                IncrementalSyncInterval = '24:00:00'
                AcceptLargeDataLoss     = $true
            }
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
