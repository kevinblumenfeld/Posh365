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
            Connect-PoshGraph -Tenant $Tenant

            $Headers = @{
                "Authorization" = "Bearer $Token"
            }

            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/v1.0/users/{0}/mailFolders/{1}/messages" -f 'Test100@kevdev.onmicrosoft.com', 'AAMkADRiN2I3NzQ5LTkzY2MtNDZjYS1iOGFkLTM4ZDQ0OGRmMDEyNgAuAAAAAADEIUNUZOaBRJPcTFR7_2l1AQAMb3L1MNkzQpQjdg15ILh9AAAAAAEKAAA='
                Headers = $Headers
                Method  = 'Get'
            }
            $Response = Invoke-RestMethod @RestSplat -Verbose:$false
            $Mail = $Response.value
            foreach ($CurMail in $Mail) {

                $CurMail| Select-Object *
                # [PSCustomObject]@{
                #     'Mailbox'                 = $UPN
                #     'FolderName'              = $FolderName
                #     'WellKnownName'           = $WellKnownFolderName
                #     'subject'                 = $CurMail.subject
                #     'sender'                  = $CurMail.sender.emailaddress
                #     'toRecipients'            = $CurMail.toRecipients.emailaddress
                #     'bccRecipients'           = $CurMail.bccRecipients
                #     'body'                    = $CurMail.body
                #     'bodyPreview'             = $CurMail.bodyPreview
                #     'categories'              = $CurMail.categories
                #     'ccRecipients'            = $CurMail.ccRecipients
                #     'from'                    = $CurMail.from
                #     'hasAttachments'          = $CurMail.hasAttachments
                #     'id'                      = $CurMail.id
                #     'importance'              = $CurMail.importance
                #     'inferenceClassification' = $CurMail.inferenceClassification
                #     'internetMessageId'       = $CurMail.internetMessageId
                #     'replyTo'                 = $CurMail.replyTo
                #     'sentDateTime'            = $CurMail.sentDateTime
                #     'webLink'                 = $CurMail.webLink

                # }
            }
        }
    }
    end {

    }

}
