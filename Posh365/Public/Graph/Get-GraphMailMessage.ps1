function Get-GraphMailMessage {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string] $Tenant,

        [Parameter(ValueFromPipeline)]
        $MailboxAndFolder

    )
    begin {

    }
    process {
        foreach ($CurMailboxAndFolder in $MailboxAndFolder) {
            $UPN = $CurMailboxAndFolder.UserPrincipalName
            $FolderName = $CurMailboxAndFolder.DisplayName
            $WellKnownFolderName = $CurMailboxAndFolder.WellKnownName
            $FolderId = $CurMailboxAndFolder.FolderId
            $Token = Connect-Graph -Tenant $Tenant

            $Headers = @{
                "Authorization" = "Bearer $Token"
            }

            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/beta/users/{0}/mailFolders/{1}/messages" -f $UPN, $FolderId
                Headers = $Headers
                Method  = 'Get'
            }
            $Response = Invoke-RestMethod @RestSplat -Verbose:$false
            $Mail = $Response.value
            foreach ($CurMail in $Mail) {

                [PSCustomObject]@{
                    'Mailbox'                 = $UPN
                    'FolderName'              = $FolderName
                    'WellKnownName'           = $WellKnownFolderName
                    'subject'                 = $CurMail.subject
                    'sender'                  = $CurMail.sender.emailaddress
                    'toRecipients'            = $CurMail.toRecipients.emailaddress
                    'bccRecipients'           = $CurMail.bccRecipients
                    'body'                    = $CurMail.body
                    'bodyPreview'             = $CurMail.bodyPreview
                    'categories'              = $CurMail.categories
                    'ccRecipients'            = $CurMail.ccRecipients
                    'from'                    = $CurMail.from
                    'hasAttachments'          = $CurMail.hasAttachments
                    'id'                      = $CurMail.id
                    'importance'              = $CurMail.importance
                    'inferenceClassification' = $CurMail.inferenceClassification
                    'internetMessageId'       = $CurMail.internetMessageId
                    'replyTo'                 = $CurMail.replyTo
                    'sentDateTime'            = $CurMail.sentDateTime
                    'webLink'                 = $CurMail.webLink

                }
            }
        }
    }
    end {

    }

}
