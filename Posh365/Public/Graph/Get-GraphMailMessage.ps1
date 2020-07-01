function Get-GraphMailMessage {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string]
        $Tenant,

        [Parameter(Mandatory)]
        [string]
        $Id,

        [Parameter(ValueFromPipeline)]
        $MailboxList

    )
    begin {

    }
    process {
        foreach ($Mailbox in $MailboxList) {
            ($Token = Connect-PoshGraph -Tenant $Tenant).access_token

            $Headers = @{ "Authorization" = "Bearer $Token" }
            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/beta/users/{0}/mailFolders/{1}/messages" -f $Mailbox.UserPrincipalName, $Id
                Headers = $Headers
                Method  = 'Get'
            }
            do {
                $Token = Connect-PoshGraph -Tenant $Tenant
                try {
                    $Response = Invoke-RestMethod @RestSplat -Verbose:$false -ErrorAction Stop
                    if ($Response.'@odata.nextLink' -match 'skip') { $Next = $Response.'@odata.nextLink' }
                    else { $Next = $null }

                    $RestSplat = @{
                        Uri     = $Next
                        Headers = $Headers = @{ "Authorization" = "Bearer $Token" }
                        Method  = 'Get'
                    }
                    foreach ($User in $Response.value) {
                        [PSCustomObject]@{
                            DisplayName       = $User.DisplayName
                            UserPrincipalName = $User.UserPrincipalName
                            Mail              = $User.Mail
                            Id                = $User.Id
                        }
                    }
                }
                catch {
                    Write-Host "$User - $($_.Exception.Message)" -ForegroundColor Red
                }
            } until (-not $next)

            # $Token = Connect-PoshGraph -Tenant $Tenant
            # $Headers = @{
            #     "Authorization" = "Bearer $Token"
            # }
            # $RestSplat = @{
            #     Uri     = "https://graph.microsoft.com/beta/users/{0}/mailFolders/{1}/messages" -f 'Test100@kevdev.onmicrosoft.com', 'AAMkADRiN2I3NzQ5LTkzY2MtNDZjYS1iOGFkLTM4ZDQ0OGRmMDEyNgAuAAAAAADEIUNUZOaBRJPcTFR7_2l1AQAMb3L1MNkzQpQjdg15ILh9AAAAAAEKAAA='
            #     Headers = $Headers
            #     Method  = 'Get'
            # }
            # $Response = Invoke-RestMethod @RestSplat -Verbose:$false
            # $Mail = $Response.value
            # foreach ($CurMail in $Mail) {
            #     $CurMail| Select-Object *
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
            #     }
            # }
        }
        end {

        }

    }
}
