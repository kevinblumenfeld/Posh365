function Resume-MailboxSync {

    param (

        [Parameter(ValueFromPipeline, Mandatory)]
        [ValidateNotNullOrEmpty()]
        $UserList,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Tenant,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        $CompleteAfter

    )
    begin {

        $CredentialPath = "${env:\userprofile}\$Tenant.Migrations.Cred"

        if (Test-Path $CredentialPath) {
            $RemoteCred = Import-CliXml -Path $CredentialPath
        }
        else {
            $RemoteCred = Get-Credential
            $RemoteCred | Export-CliXml -Path $CredentialPath
        }
        if ($CompleteAfter) {
            $when = $CompleteAfter
        }
        else {
            $when = (Get-Date).AddDays(-1)
        }
    }
    process {
        foreach ($User in $UserList) {
            $Param = @{
                Identity                   = $User.UserPrincipalName
                BatchName                  = $User.Batch
                SuspendWhenReadyToComplete = $False
                Confirm                    = $False
                CompleteAfter              = $when
            }
            Set-MoveRequest @Param
            Resume-MoveRequest $User.UserPrincipalName
        }
    }
}
