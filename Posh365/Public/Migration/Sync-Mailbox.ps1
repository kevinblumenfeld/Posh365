function Sync-Mailbox {
    <#
    .SYNOPSIS
    Sync Mailboxes from On-Premises Exchange to Exchange Online

    .DESCRIPTION
    Sync Mailboxes from On-Premises Exchange to Exchange Online

    .PARAMETER MailboxCSV
    Path to csv of mailboxes.  Minimum headers required are: Batch, UserPrincipalName

    .PARAMETER RemoteHost
    This is the endpoint where the source mailboxes reside ex. cas2010.contoso.com

    .PARAMETER TargetDomain
    This is the tenant domain ex. if tenant is contoso.mail.onmicrosoft.com use contoso

    .PARAMETER GroupsToAddUserTo
    Provide one or more groups to add each user chosen to. -GroupsToAddUserTo "Human Resources", "Accounting"
    Requires AD Module

    .PARAMETER DeleteSavedCredential
    Erases credentials that are saved and encrypted on your computer

    .EXAMPLE
    Sync-Mailbox -RemoteHost cas2010.contoso.com -TargetDomain contoso -MailboxCSV c:\scripts\batches.csv -GroupsToAddUserTo "Office 365 E3"

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
        [ValidateNotNullOrEmpty()]
        [string[]]
        $GroupsToAddUserTo,

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
        Connect-Cloud -Tenant $TargetDomain -ExchangeOnline
        $UserChoice = Get-UserDecision -MailboxCSV $MailboxCSV
        if ($UserChoice) {
            $Sync = @{
                RemoteHost   = $RemoteHost
                TargetDomain = $TargetDomain
            }
            $UserChoice | Start-MailboxSync @Sync
            foreach ($Group in $GroupsToAddUserTo) {
                $GuidList = $UserChoice | Get-ADUserGuid
                $GuidList | Add-UserToADGroup -Group $Group
            }
        }
    }
}
