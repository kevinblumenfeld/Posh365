function Invoke-NewMailboxMove {
    <#
    .SYNOPSIS
    Sync Mailboxes from On-Premises Exchange to Exchange Online

    .DESCRIPTION
    Sync Mailboxes from On-Premises Exchange to Exchange Online

    .PARAMETER UserList
    Passed via pipeline from public function

    .PARAMETER RemoteHost
    This is the on-premises endpoint where the source mailboxes reside ex. cas2010.contoso.com

    .PARAMETER Tenant
    This is the tenant domain ex. if tenant is contoso.mail.onmicrosoft.com use contoso

    .EXAMPLE

    .NOTES
    General notes
    #>

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
