function Send-PoshMessage {
    param (
        [Parameter(Mandatory)]
        $Tenant,

        [Parameter()]
        $SMTPServer = 'smtp.sendgrid.net',

        [Parameter()]
        $Port = 587,

        [Parameter()]
        $Sender,

        [Parameter()]
        $Recipient,

        [Parameter()]
        $Subject = 'Subject Test',

        [Parameter()]
        [string]
        $Body = 'Test in the body of the message',

        [Parameter()]
        [switch]
        $Unauthenticated,

        [Parameter()]
        [switch]
        $BodyAsHTML,

        [Parameter()]
        [switch]
        $DontUseSSL,

        [Parameter()]
        [ValidateSet('Low', 'Normal', 'High')]
        [string]
        $Priority = 'Normal',

        [Parameter()]
        [switch]
        $DeleteCreds
    )

    $TenantCred = Join-Path -Path $Env:USERPROFILE -ChildPath ('{0}{1}Cred.xml' -f $Tenant, $SMTPServer)
    $UseSSL = $true
    if ($DontUseSSL) { $UseSSL = $false }

    if ($DeleteCreds) {
        Remove-Item -Path $TenantCred -Force
        continue
    }
    if (-not (Test-Path $TenantCred)) {
        $Timport = Get-Credential
        $Timport | Export-CliXml $TenantCred
    }
    $TImport = Import-Clixml $TenantCred

    [PSCredential]$Credential = Import-Clixml -Path $TenantCred

    $SendParams = @{
        SmtpServer = $SMTPServer
        Port       = $Port
        UseSSL     = $UseSSL
        From       = $Sender
        To         = $Recipient
        Body       = $Body
        BodyasHTML = $BodyAsHTML
        Subject    = $Subject
        Priority   = $Priority
    }
    if (-not $Unauthenticated) {
        $SendParams['Credential'] = $Credential
    }
    Send-MailMessage @SendParams
}
