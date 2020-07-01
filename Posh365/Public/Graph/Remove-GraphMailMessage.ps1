function Remove-GraphMailMessage {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string] $Tenant,

        [Parameter(ValueFromPipeline)]
        $IDList

    )
    begin {

    }
    process {
        foreach ($ID in $IDList) {
            $Token = Connect-PoshGraph -Tenant $Tenant

            $Headers = @{
                "Authorization" = "Bearer $Token"
            }
            write-host "ID: $($id.id)"
            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/beta/users/{0}/mailFolders/{1}/messages/{2}" -f 'Test100@kevdev.onmicrosoft.com', 'AAMkADRiN2I3NzQ5LTkzY2MtNDZjYS1iOGFkLTM4ZDQ0OGRmMDEyNgAuAAAAAADEIUNUZOaBRJPcTFR7_2l1AQAMb3L1MNkzQpQjdg15ILh9AAAAAAEKAAA=', $id.id
                Headers = $Headers
                Method  = 'DELETE'
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
