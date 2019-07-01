function Start-MailboxSync {
    <#
    .SYNOPSIS
    Sync Mailboxes from On-Premises Exchange to Exchange Online

    .DESCRIPTION
    Sync Mailboxes from On-Premises Exchange to Exchange Online

    .PARAMETER UserList
    Passed via pipeline from public function

    .PARAMETER RemoteHost
    This is the endpoint where the source mailboxes reside ex. cas2010.contoso.com

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
        $LargeItemLimit,

        [Parameter()]
        [switch]
        $DeleteSavedCredential

    )
    begin {

        $CredentialPath = "${env:\userprofile}\$Tenant.Migrations.Cred"

        if ($DeleteSavedCredential) {
            Remove-Item $CredentialPath
        }
        if (Test-Path $CredentialPath) {
            $RemoteCred = Import-CliXml -Path $CredentialPath
        }
        else {
            $RemoteCred = Get-Credential
            $RemoteCred | Export-CliXml -Path $CredentialPath
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
            New-MoveRequest @Param -warningaction silentlycontinue
        }
    }
}
