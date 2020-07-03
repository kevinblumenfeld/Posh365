function Remove-GraphMailMessage {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string]
        $Tenant,

        [Parameter(ValueFromPipeline)]
        $IDList

    )
    begin {
        $i = 0
    }
    process {
        foreach ($ID in $IDList) {
            $i++
            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/v1.0/users/{0}/mailFolders/{1}/messages/{2}" -f $Id.UserPrincipalName, $Id.ParentFolderId, $Id.Id
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'Delete'
            }
            $Response = Invoke-RestMethod @RestSplat
            Write-Verbose "Response $i`t $Response"
        }
    }
}
