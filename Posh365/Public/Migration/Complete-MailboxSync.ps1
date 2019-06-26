function Complete-MailboxSync {
    <#
    .SYNOPSIS
    Sync Mailboxes from On-Premises Exchange to Exchange Online
    Either CSV or Excel file from SharePoint can be used

    .DESCRIPTION
    Sync Mailboxes from On-Premises Exchange to Exchange Online
    Either CSV or Excel file from SharePoint can be used

    .PARAMETER SharePointURL
    Sharepoint url ex. https://contoso.sharepoint.com/sites/fabrikam/

    .PARAMETER ExcelFile
    Excel file found in "Shared Documents" of SharePoint site specified in SharePointURL
    ex. "Batchex.xlsx"

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
    Sync-Mailbox -RemoteHost cas2010.contoso.com -Tenant contoso -MailboxCSV c:\scripts\batches.csv -GroupsToAddUserTo "Office 365 E3"

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Tenant,

        [Parameter()]
        [switch]
        $Schedule

    )
    end {
        if ($Tenant -notmatch '.mail.onmicrosoft.com') {
            $Tenant = "$Tenant.mail.onmicrosoft.com"
        }
        $OGVMR = @{
            Title      = 'Choose Mailboxes to Complete'
            OutputMode = 'Multiple'
        }

        $UserChoice = Get-EXOMoveRequest | Sort-Object @(
            @{
                Expression = "BatchName"
                Descending = $true
            }
            @{
                Expression = "DisplayName"
                Descending = $false
            }
        ) | Out-GridView @OGVMR

        if ($UserChoice) {
            Connect-Cloud -Tenant $Tenant -ExchangeOnline
            if ($Schedule) {
                $UTCTimeandDate = Get-ScheduleDecision
                $UserChoice | Resume-MailboxSync -Tenant $Tenant -CompleteAfter $UTCTimeandDate
            }
            else {
                $UserChoice | Resume-MailboxSync -Tenant $Tenant
            }

        }
    }
}

