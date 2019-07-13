function Remove-MailboxMoveCredential {
    <#
    .SYNOPSIS
    Erases credentials that are saved and encrypted on your computer
    These are the on premises Exchange endpoint credentials.

    .DESCRIPTION
    Erases credentials that are saved and encrypted on your computer
    These are the on premises Exchange endpoint credentials.

    .PARAMETER Tenant
    This is the tenant domain - where you are/were migrating to
    Example: If target tenant is contoso.mail.onmicrosoft.com use contoso

    .EXAMPLE
    Remove-MailboxMoveCredentials -Tenant Contoso

    .NOTES
    General notes
    #>

    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Tenant
    )
    end {
        if ($Tenant -notmatch '.mail.onmicrosoft.com') {
            $Tenant = '{0}.mail.onmicrosoft.com' -f $Tenant
        }
        $CredentialPath = "${env:\userprofile}\$Tenant.Migrations.Cred"
        Remove-Item $CredentialPath -ErrorAction SilentlyContinue
    }
}
