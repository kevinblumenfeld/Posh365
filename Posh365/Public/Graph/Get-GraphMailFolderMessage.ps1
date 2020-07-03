function Get-GraphMailFolderMessage {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string]
        $Tenant,

        [Parameter(Mandatory)]
        [ValidateSet('archive', 'clutter', 'conflicts', 'conversationhistory', 'DeletedItems', 'drafts', 'Inbox', 'junkemail', 'localfailures', 'msgfolderroot', 'outbox', 'recoverableitemsdeletions', 'scheduled', 'searchfolders', 'sentitems', 'serverfailures', 'syncissues')]
        $WellKnownFolder,

        [Parameter()]
        [datetime]
        $MessagesOlderThan,

        [Parameter()]
        [datetime]
        $MessagesNewerThan,

        [Parameter()]
        [int]
        $Top,

        [Parameter(ValueFromPipeline)]
        $MailboxList

    )
    begin {
        if ($MessagesOlderThan -and $MessagesNewerThan) {
            Write-Host 'Choose only one date, MessagesOlderThan OR MessagesNewerThan' -ForegroundColor Red
            return
        }
        $filterstring = [System.Collections.Generic.List[string]]::new()

        if ($MessagesOlderThan) {
            $filter = "`$filter=ReceivedDateTime le {0}" -f $MessagesOlderThan.ToUniversalTime().ToString('O')
            $filterstring.Add($filter)
        }
        elseif ($MessagesNewerThan) {
            $filter = "`$filter=ReceivedDateTime ge {0}" -f $MessagesNewerThan.ToUniversalTime().ToString('O')
            $filterstring.Add($filter)
        }
        if ($Top) { $filterstring.Add(('`$top={0}' -f $Top)) }
        if ($filterstring) { $Uri = '/messages?{0}' -f (@($filterstring) -ne '' -join '&') }
        else { $Uri = '/messages' }
        write-Host "$URI" -ForegroundColor Cyan
    }
    process {
        foreach ($Mailbox in $MailboxList) {
            $RestSplat = @{
                Uri         = "https://graph.microsoft.com/v1.0/users/{0}/mailFolders('{1}'){2}" -f $Mailbox.UserPrincipalName, $WellKnownFolder, $Uri
                Headers     = @{ "Authorization" = "Bearer $Token" }
                Method      = 'Get'
                ErrorAction = 'Stop'
            }
            $i = if ($Top) { $Top } else { 10000000 }
            do {
                if ([datetime]::UtcNow -ge $Script:TimeToRefresh) { Connect-PoshGraphRefresh }
                try {
                    $MessageList = Invoke-RestMethod @RestSplat -Verbose:$false
                    if ($MessageList.'@odata.nextLink' -match 'skip') { $Next = $MessageList.'@odata.nextLink' }
                    else { $Next = $null }

                    $RestSplat = @{
                        Uri         = $Next
                        Headers     = @{ "Authorization" = "Bearer $Token" }
                        Method      = 'Get'
                        ErrorAction = 'Stop'
                    }
                    foreach ($Message in $MessageList.Value) {
                        $i -= 1
                        [PSCustomObject]@{
                            DisplayName          = $Mailbox.DisplayName
                            UserPrincipalName    = $Mailbox.UserPrincipalName
                            Mail                 = $Mailbox.Mail
                            Sender               = $Message.Sender
                            from                 = $Message.from
                            replyTo              = $Message.replyTo
                            toRecipients         = $Message.toRecipients
                            Subject              = $Message.Subject
                            Body                 = $Message.Body
                            BodyPreview          = $Message.BodyPreview
                            Id                   = $Message.Id
                            ParentFolderId       = $Message.parentFolderId
                            ReceivedDateTime     = $Message.ReceivedDateTime
                            sentDateTime         = $Message.sentDateTime
                            createdDateTime      = $Message.createdDateTime
                            lastModifiedDateTime = $Message.lastModifiedDateTime
                        }
                    }
                }
                catch { Write-Host "$($Mailbox.UserPrincipalName) ERROR: $($_.Exception.Message)" -ForegroundColor Red }
                # Write-Host "$i" -ForegroundColor Green
            } until (-not $next -or $i -lt 1)
        }
    }
}
