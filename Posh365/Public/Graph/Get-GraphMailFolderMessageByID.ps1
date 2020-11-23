function Get-GraphMailFolderMessageByID {
    [CmdletBinding()]
    param (

        [Parameter()]
        [datetime]
        $MessagesOlderThan,

        [Parameter()]
        [datetime]
        $MessagesNewerThan,

        [Parameter()]
        [string]
        [Alias('_Message_Body')]
        $Body,

        [Parameter()]
        [Alias('_Message_Subject')]
        [string]
        $Subject,

        [Parameter()]
        [Alias('_Message_From')]
        [string]
        $From,

        [Parameter()]
        [Alias('_Message_CC')]
        [string]
        $CC,

        [Parameter()]
        [Alias('Count')]
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
        if ($Subject) {
            $filter = "`$search=""Subject:{0}""" -f $Subject
            $filterstring.Add($filter)
        }
        if ($Body) {
            $filter = "`$search=""Body:{0}""" -f $Body
            $filterstring.Add($filter)
        }
        if ($From) {
            $filter = "`$search=""From:{0}""" -f $From
            $filterstring.Add($filter)
        }
        if ($CC) {
            $filter = "`$search=""CC:{0}""" -f $CC
            $filterstring.Add($filter)
        }
        if ($Top) { $filterstring.Add(('`$top={0}' -f $Top)) }
        if ($filterstring) { $Uri = '/messages?{0}' -f (@($filterstring) -ne '' -join '&') }
        else { $Uri = '/messages' }
    }
    process {
        foreach ($Mailbox in $MailboxList) {
            $RestSplat = @{
                Uri         = "https://graph.microsoft.com/v1.0/users/{0}/mailFolders('{1}'){2}" -f $Mailbox.UserPrincipalName, $Mailbox.ID, $Uri
                Headers     = @{ "Authorization" = "Bearer $Token" }
                Method      = 'Get'
                ErrorAction = 'Stop'
            }
            $i = if ($Top) { $Top } else { 10000000 }
            do {
                if ([datetime]::UtcNow -ge $TimeToRefresh) { Connect-PoshGraphRefresh }
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
                            Folder               = $Mailbox.Folder
                            Path                 = $Mailbox.Path
                            SenderName           = $Message.Sender.emailaddress.name
                            SenderAddress        = $Message.Sender.emailaddress.address
                            FromName             = $Message.from.emailaddress.name
                            FromAddress          = $Message.from.emailaddress.address
                            replyTo              = $Message.replyTo
                            toRecipientsName     = $Message.toRecipients.emailaddress.name
                            toRecipientsAddress  = $Message.toRecipients.emailaddress.address
                            Subject              = $Message.Subject
                            BodyPreview          = $Message.BodyPreview
                            ccRecipientsName     = $Message.ccRecipients.emailaddress.name
                            ccRecipientsAddress  = $Message.ccRecipients.emailaddress.address
                            bccRecipientsName    = $Message.bccRecipients.emailaddress.name
                            bccRecipientsAddress = $Message.bccRecipients.emailaddress.address
                            Body                 = $Message.Body.content
                            ReceivedDateTime     = $Message.ReceivedDateTime
                            sentDateTime         = $Message.sentDateTime
                            createdDateTime      = $Message.createdDateTime
                            lastModifiedDateTime = $Message.lastModifiedDateTime
                            Id                   = $Message.Id
                            ParentFolderId       = $Message.parentFolderId
                        }
                    }
                }
                catch { }
            } until (-not $next -or $i -lt 1)
        }
    }
}
