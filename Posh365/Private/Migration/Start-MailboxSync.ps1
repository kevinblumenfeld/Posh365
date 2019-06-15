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

    .PARAMETER TargetDomain
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
        $TargetDomain,

        [Parameter()]
        [switch]
        $DeleteSavedCredential

    )
    begin {
        if ($TargetDomain -notmatch '.mail.onmicrosoft.com') {
            $TargetDomain = "$TargetDomain.mail.onmicrosoft.com"
        }

        $CredentialPath = "${env:\userprofile}\$TargetDomain.Migrations.Cred"

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
                BatchName                  = $User.Batch
                TargetDeliveryDomain       = $TargetDomain
                SuspendWhenReadyToComplete = $true
                LargeItemLimit             = "20"
                BadItemLimit               = "20"
                AcceptLargeDataLoss        = $true
            }
            New-MoveRequest @Param -verbose
        }
    }
}
