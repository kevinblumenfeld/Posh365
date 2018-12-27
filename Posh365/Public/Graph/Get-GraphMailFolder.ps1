function Get-GraphMailFolder {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string] $Tenant,

        [Parameter()]
        [ValidateSet('archive', 'clutter', 'conflicts', 'conversationhistory', 'deleteditems', 'drafts', 'inbox', 'junkemail', 'localfailures', 'msgfolderroot', 'outbox', 'recoverableitemsdeletions', 'scheduled', 'searchfolders', 'sentitems', 'serverfailures', 'syncissues')]
        $WellKnownFolder,

        [Parameter(ValueFromPipeline)]
        $User

    )
    begin {

    }
    process {
        foreach ($CurUser in $User) {
            $DisplayName = $CurUser.DisplayName
            $UPN = $CurUser.UserPrincipalName
            $Mail = $CurUser.Mail
            $Id = $CurUser.Id
            $Token = Connect-Graph -Tenant $Tenant

            $Headers = @{
                "Authorization" = "Bearer $Token"
            }

            $RestSplat = @{
                Uri     = 'https://graph.microsoft.com/beta/users/{0}/mailFolders' -f $Id
                Headers = $Headers
                Method  = 'Get'
            }
            $Response = Invoke-WebRequest @RestSplat -Verbose:$false
            $Headers = $Response.Headers
            $Folder = ($Response.Content | ConvertFrom-Json).value
            if ($WellKnownFolder) {
                $Folder = $Folder.Where{$_.wellKnownName -eq $WellKnownFolder}
            }
            foreach ($CurFolder in $Folder) {
                [PSCustomObject]@{
                    DisplayName       = $DisplayName
                    UserPrincipalName = $UPN
                    Mail              = $Mail
                    Id                = $Id
                    FolderName        = $CurFolder.DisplayName
                    wellKnownName     = $CurFolder.wellKnownName
                    FolderId          = $CurFolder.Id
                }
            }
        }
    }
    end {

    }

}
