function Get-GraphMailFolderMessage {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string]
        $Tenant,

        [Parameter(Mandatory)]
        [ValidateSet('archive', 'clutter', 'conflicts', 'conversationhistory', 'deleteditems', 'drafts', 'inbox', 'junkemail', 'localfailures', 'msgfolderroot', 'outbox', 'recoverableitemsdeletions', 'scheduled', 'searchfolders', 'sentitems', 'serverfailures', 'syncissues')]
        $WellKnownFolder,

        [Parameter(ValueFromPipeline)]
        $UserList

    )
    process {
        foreach ($User in $UserList) {
            ($Token = Connect-PoshGraph -Tenant $Tenant).access_token
            $Headers = @{ "Authorization" = "Bearer $Token" }
            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/beta/users/{0}/mailFolders('{1}')/messages" -f $User.UserPrincipalName, $WellKnownFolder
                Headers = $Headers
                Method  = 'Get'
            }
            Invoke-RestMethod @RestSplat -Verbose:$false

            do {
                ($Token = Connect-PoshGraph -Tenant $Tenant).access_token
                try {
                    $Response = Invoke-RestMethod @RestSplat -Verbose:$false -ErrorAction Stop
                    if ($Response.'@odata.nextLink' -match 'skip') { $Next = $Response.'@odata.nextLink' }
                    else { $Next = $null }
                    $Headers = @{ "Authorization" = "Bearer $Token" }

                    $RestSplat = @{
                        Uri     = $Next
                        Headers = $Headers
                        Method  = 'Get'
                    }
                    foreach ($Response in $Response.Value) {
                        [PSCustomObject]@{
                            DisplayName       = $User.DisplayName
                            UserPrincipalName = $User.UserPrincipalName
                            Mail              = $User.
                            Id                = $Id
                            FolderName        = $Response.DisplayName
                            wellKnownName     = $Response.wellKnownName
                            FolderId          = $Response.Id
                            ParentFolderId    = $Response.parentFolderId
                            nextLink          = $Response.'@odata.nextLink'
                        }
                    }
                }
                catch {
                    Write-Host "$User - $($_.Exception.Message)" -ForegroundColor Red
                }
            } until (-not $next)
        }
    }
}
