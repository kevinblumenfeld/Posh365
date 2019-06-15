function Sync-Mailbox {
    <#
    .SYNOPSIS
    Sync Mailboxes from On-Premises Exchange to Exchange Online

    .DESCRIPTION
    Sync Mailboxes from On-Premises Exchange to Exchange Online

    .PARAMETER MailboxCSV
    Path to csv of mailboxes.  Headers needed are minimum: Batch, UserPrincipalName

    .PARAMETER RemoteHost
    This is the endpoint where the source mailboxes reside ex. cas2010.contoso.com

    .PARAMETER TargetDomain
    This is the tenant domain ex. if tenant is contoso.mail.onmicrosoft.com use contoso

    .PARAMETER DeleteSavedCredential
    Erases credentials that are saved and encrypted on your computer

    .EXAMPLE
    Invoke-MailboxSync -RemoteHost cas2010.contoso.com -TargetDomain contoso -MailboxCSV c:\scripts\batches.csv

    .NOTES
    General notes
    #>

    param (

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        $MailboxCSV,

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
    end {
        if ($DeleteSavedCredential) {
            $DelSaved = @{
                RemoteHost            = $RemoteHost
                TargetDomain          = $TargetDomain
                DeleteSavedCredential = $true
            }
            Start-MailboxSync @DelSaved
            break
        }

        if ($TargetDomain -notmatch '.mail.onmicrosoft.com') {
            $TargetDomain = "$TargetDomain.mail.onmicrosoft.com"
        }
        $Mailbox = Import-Csv -Path $MailboxCSV

        $OGVBatch = @{
            Title      = 'Choose Batch(es)'
            OutputMode = 'Multiple'
        }

        $OGVUser = @{
            Title      = 'Choose User(s)'
            OutputMode = 'Multiple'
        }

        $OGVDecision = @{
            Title      = 'Migrate Users or Quit?'
            OutputMode = 'Single'
        }

        $BatchChoice = $Mailbox | Select-Object -ExpandProperty Batch -Unique | Out-GridView @OGVBatch
        $UserChoice = $Mailbox | Where-Object { $_.Batch -in $BatchChoice } | Out-GridView @OGVUser

        if ($UserChoice) {
            $Decision = 'Migrate', 'Quit' | Out-GridView @OGVDecision
        }

        if ($Decision -eq 'Migrate') {
            $Sync = @{
                RemoteHost   = $RemoteHost
                TargetDomain = $TargetDomain
            }
            $UserChoice | Start-MailboxSync @Sync
        }
    }
}
