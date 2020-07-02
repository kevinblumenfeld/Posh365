function Remove-GraphMailMessage {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string] $Tenant,

        [Parameter(ValueFromPipeline)]
        $IDList

    )
    begin {
        Connect-PoshGraph -Tenant $Tenant
    }
    process {
        foreach ($ID in $IDList) {
            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/beta/users/{0}/mailFolders/{1}/messages/{2}" -f $Id.UserPrincipalName, $Id.ParentFolderId, $Id.Id
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'Delete'
            }
            Invoke-RestMethod @RestSplat -Verbose:$false
        }
    }
}
