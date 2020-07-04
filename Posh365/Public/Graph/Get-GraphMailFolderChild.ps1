function Get-GraphMailFolderChild {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $UserPrincipalName,

        [Parameter(ValueFromPipeline)]
        $FolderList
    )
    process {
        foreach ($Folder in $FolderList) {
            Write-Host "Mailbox: $UserPrincipalName" -ForegroundColor Green
            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/beta/users/{0}/mailFolders/{1}/childFolders" -f $UserPrincipalName, $Folder.Id
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'Get'
            }
            $Children = (Invoke-RestMethod @RestSplat -Verbose:$false).value
            foreach ($Child in $Children) {
                [PSCustomObject]@{
                    UserPrincipalName = $UserPrincipalName
                    DisplayName       = $Child.DisplayName
                    ParentFolderId    = $Child.ParentFolderId
                    ChildFolderCount  = $Child.ChildFolderCount
                    unreadItemCount   = $Child.unreaditemCount
                    totalItemCount    = $Child.unreaditemCount
                    wellKnownName     = $Child.wellKnownName
                }
                if ($Child.ChildFolderCount -ge 1) {
                    $Child | Get-GraphMailFolderChild -UserPrincipalName $UserPrincipalName
                }
            }
        }
    }
}
