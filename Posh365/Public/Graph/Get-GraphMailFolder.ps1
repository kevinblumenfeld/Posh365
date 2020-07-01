function Get-GraphMailFolder {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string] $Tenant,

        [Parameter()]
        [ValidateSet('archive', 'clutter', 'conflicts', 'conversationhistory', 'deleteditems', 'drafts', 'inbox', 'junkemail', 'localfailures', 'msgfolderroot', 'outbox', 'recoverableitemsdeletions', 'scheduled', 'searchfolders', 'sentitems', 'serverfailures', 'syncissues')]
        $WellKnownFolder,

        [Parameter(ValueFromPipeline)]
        $MailboxList

    )
    begin {
        Connect-PoshGraph -Tenant $Tenant
    }
    process {
        foreach ($Mailbox in $MailboxList) {
            Write-Host "Mailbox: $($Mailbox.UserPrincipalName)" -ForegroundColor Green
            # $RestSplat = @{
            #     # Uri     = "https://graph.microsoft.com/beta/users/{0}/mailFolders('{1}')/messages" -f $UPN, 'deleteditems'
            #     Uri     = 'https://graph.microsoft.com/beta/users/{0}/mailFolders' -f $Mailbox.UserPrincipalName
            #     Headers = @{ "Authorization" = "Bearer $Token" }
            #     Method  = 'Get'
            # }

            # $RestSplat = @{
            #     Uri     = 'https://graph.microsoft.com/beta/users/{0}/mailFolders' -f $Id
            #     Headers = $Headers
            #     Method  = 'Get'
            # }
            # $RestSplat = @{
            #     Uri     = "https://graph.microsoft.com/beta/users/{0}/mailFolders('{1}')/messages" -f $Id, $WellKnownFolder
            #     Headers = $Headers
            #     Method  = 'Get'
            # }
            # $RestSplat = @{
            #     Uri     = "https://graph.microsoft.com/beta/users/{0}/mailFolders('{1}')/childFolders" -f $Id, $WellKnownFolder
            #     Headers = $Headers
            #     Method  = 'Get'
            # }

            $RestSplat = @{
                Uri     = 'https://graph.microsoft.com/beta/users/{0}/mailFolders/msgfolderroot/childFolders' -f $Mailbox.UserPrincipalName
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'Get'
            }
            $Response = Invoke-RestMethod @RestSplat -Verbose:$true
            $Response.value

            # do {
            #     $Token = Connect-PoshGraph -Tenant $Tenant
            #     try {
            #         $Response = Invoke-RestMethod @RestSplat -Verbose:$false -ErrorAction Stop
            #         $Folder = $Response.value
            #         <#
            #         if ($WellKnownFolder) {
            #             $Folder = $Folder.Where{$_.wellKnownName -eq $WellKnownFolder}
            #         }
            #         #>

            #         if ($Response.'@odata.nextLink' -match 'skip') {
            #             $Next = $Response.'@odata.nextLink'
            #         }
            #         else {
            #             $Next = $null
            #         }
            #         $Headers = @{
            #             "Authorization" = "Bearer $Token"
            #         }

            #         $RestSplat = @{
            #             Uri     = $Next
            #             Headers = $Headers
            #             Method  = 'Get'
            #         }
            #         foreach ($CurFolder in $Folder) {
            #             [PSCustomObject]@{
            #                 DisplayName       = $DisplayName
            #                 UserPrincipalName = $UPN
            #                 Mail              = $Mail
            #                 Id                = $Id
            #                 FolderName        = $CurFolder.DisplayName
            #                 wellKnownName     = $CurFolder.wellKnownName
            #                 FolderId          = $CurFolder.Id
            #                 ParentFolderId    = $CurFolder.parentFolderId
            #                 nextLink          = $Response.'@odata.nextLink'
            #             }
            #         }
            #     }
            #     catch {
            #         $errormessage = $_.exception.message
            #         Write-Host "$UPN"
            #         write-host "$errormessage"
            #     }
            # } until (-not $next)
        }
    }
}
