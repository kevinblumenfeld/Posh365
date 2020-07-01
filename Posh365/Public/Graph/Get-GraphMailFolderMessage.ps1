function Get-GraphMailFolderMessage {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string]
        $Tenant,

        [Parameter(Mandatory)]
        [ValidateSet('archive', 'clutter', 'conflicts', 'conversationhistory', 'DeletedItems', 'drafts', 'Inbox', 'junkemail', 'localfailures', 'msgfolderroot', 'outbox', 'recoverableitemsdeletions', 'scheduled', 'searchfolders', 'sentitems', 'serverfailures', 'syncissues')]
        $WellKnownFolder,

        [Parameter(ValueFromPipeline)]
        $MailboxList

    )
    process {
        foreach ($Mailbox in $MailboxList) {
            Connect-PoshGraph -Tenant $Tenant
            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/beta/users/{0}/mailFolders('{1}')/messages" -f $Mailbox.UserPrincipalName, $WellKnownFolder
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'Get'
            }
            do {
                try {
                    $MessageList = Invoke-RestMethod @RestSplat -Verbose:$false
                    if ($MessageList.'@odata.nextLink' -match 'skip') { $Next = $MessageList.'@odata.nextLink' }
                    else { $Next = $null }

                    $RestSplat = @{
                        Uri     = $Next
                        Headers = @{ "Authorization" = "Bearer $Token" }
                        Method  = 'Get'
                    }
                    foreach ($Message in $MessageList.Value) {
                        [PSCustomObject]@{
                            DisplayName       = $Mailbox.DisplayName
                            UserPrincipalName = $Mailbox.UserPrincipalName
                            Mail              = $Mailbox.Mail
                            Subject           = $Message.Subject
                            BodyPreview       = $Message.BodyPreview
                            Id                = $Message.Id
                            ParentFolderId    = $Message.parentFolderId
                        }
                    }
                }
                catch { Write-Host "$Mailbox - $($_.Exception.Message)" -ForegroundColor Red }
            } until (-not $next)
        }
    }
}
