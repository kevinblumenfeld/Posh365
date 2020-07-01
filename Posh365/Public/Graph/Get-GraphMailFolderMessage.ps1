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
        [Int]
        $Days,

        [Parameter(ValueFromPipeline)]
        $MailboxList

    )
    begin {
        $Date = (Get-Date).AddDays(- $Days)
    }
    process {
        foreach ($Mailbox in $MailboxList) {
            Connect-PoshGraph -Tenant $Tenant
            #$filter = '/?`$filter=ReceivedDateTime ge {0}' -f $Date.ToUniversalTime().ToString("O")
            $filter = "/?`$filter=ReceivedDateTime le 2018-12-26T19:14:29Z"

            # $filter = '/?`$select=ReceivedDateTime,Sender,Subject,IsRead,InferenceClassification`&`$Top=1000`&`$filter=ReceivedDateTime ge {0}' -f $Date.ToUniversalTime().ToString("O")
            $RestSplat = @{
                #Uri     = "https://graph.microsoft.com/beta/users/{0}/mailFolders('{1}')/messages" -f $Mailbox.UserPrincipalName, $WellKnownFolder
                Uri     = "https://graph.microsoft.com/beta/users/{0}/mailFolders('{1}')/messages{2}" -f $Mailbox.UserPrincipalName, $WellKnownFolder, $filter
                # Uri     = "https://graph.microsoft.com/beta/users/'test100@kevdev.onmicrosoft.com'/mailFolders('Inbox')/messages/?&`$filter=$filter" #-f (Get-Date).AddYears(-1).ToUniversalTime().ToString('O') #-f $Mailbox.UserPrincipalName, $WellKnownFolder #, $Date.ToUniversalTime().ToString("O")
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
                        $Message | Select *
                        # [PSCustomObject]@{
                        #     DisplayName       = $Mailbox.DisplayName
                        #     UserPrincipalName = $Mailbox.UserPrincipalName
                        #     Mail              = $Mailbox.Mail
                        #     Subject           = $Message.Subject
                        #     BodyPreview       = $Message.BodyPreview
                        #     Id                = $Message.Id
                        #     ParentFolderId    = $Message.parentFolderId
                        # }
                    }
                }
                catch { Write-Host "$Mailbox - $($_.Exception.Message)" -ForegroundColor Red }
            } until (-not $next)
        }
    }
}
