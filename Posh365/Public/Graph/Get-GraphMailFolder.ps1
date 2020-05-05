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
            $Token = Connect-PoshGraph -Tenant $Tenant
            $DisplayName = $CurUser.DisplayName
            $UPN = $CurUser.UserPrincipalName
            $Mail = $CurUser.Mail
            $Id = $CurUser.Id
            $Headers = @{
                "Authorization" = "Bearer $Token"
            }
<#
            $RestSplat = @{
                Uri     = 'https://graph.microsoft.com/beta/users/{0}/mailFolders' -f $Id
                Headers = $Headers
                Method  = 'Get'
            }
            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/beta/users/{0}/mailFolders('{1}')/messages" -f $Id, $WellKnownFolder
                Headers = $Headers
                Method  = 'Get'
            }
            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/beta/users/{0}/mailFolders('{1}')/childFolders" -f $Id, $WellKnownFolder
                Headers = $Headers
                Method  = 'Get'
            }
#>


            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/beta/users/{0}/mailFolders/msgfolderroot/childFolders" -f $Id
                Headers = $Headers
                Method  = 'Get'
            }

            do {
                $Token = Connect-PoshGraph -Tenant $Tenant
                try {
                    $Response = Invoke-RestMethod @RestSplat -Verbose:$false -ErrorAction Stop
                    $Folder = $Response.value
                    <#
                    if ($WellKnownFolder) {
                        $Folder = $Folder.Where{$_.wellKnownName -eq $WellKnownFolder}
                    }
                    #>

                    if ($Response.'@odata.nextLink' -match 'skip') {
                        $Next = $Response.'@odata.nextLink'
                    }
                    else {
                        $Next = $null
                    }
                    $Headers = @{
                        "Authorization" = "Bearer $Token"
                    }

                    $RestSplat = @{
                        Uri     = $Next
                        Headers = $Headers
                        Method  = 'Get'
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
                            ParentFolderId    = $CurFolder.parentFolderId
                            nextLink          = $Response.'@odata.nextLink'
                        }
                    }
                }
                catch {
                    $errormessage = $_.exception.message
                    Write-Host "$UPN"
                    write-host "$errormessage"
                }
            } until (-not $next)
        }
    }
    end {

    }

}
