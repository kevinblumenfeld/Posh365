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
                Identity                   = $User.UserPrincipalName
                RemoteCredential           = $RemoteCred
                Remote                     = $true
                RemoteHostName             = $RemoteHost
                BatchName                  = $User.BatchName
                TargetDeliveryDomain       = $Tenant
                SuspendWhenReadyToComplete = $true
                BadItemLimit               = $BadItemLimit
                LargeItemLimit             = $LargeItemLimit
                AcceptLargeDataLoss        = $true
                # New-MoveRequest –OutBound -Identity <mailboxguid> -RemoteTenant "Contoso.onmicrosoft.com" -TargetDeliveryDomain Contoso.onmicrosoft.com -BadItemLimit 50 -CompleteAfter (Get-Date).AddMonths(12) -IncrementalSyncInterval '24:00:00'
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