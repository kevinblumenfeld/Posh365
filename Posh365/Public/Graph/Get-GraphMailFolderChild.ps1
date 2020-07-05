function Get-GraphMailFolderChild {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $UserPrincipalName,

        [Parameter()]
        $Mail,

        [Parameter(Mandatory)]
        $DisplayName,

        [Parameter(ValueFromPipeline)]
        $FolderList
    )
    process {
        foreach ($Folder in $FolderList) {
            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/beta/users/{0}/mailFolders/{1}/childFolders" -f $UserPrincipalName, $Folder.Id
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'Get'
            }
            $Children = (Invoke-RestMethod @RestSplat -Verbose:$false).value
            foreach ($Child in $Children) {
                [PSCustomObject]@{
                    DisplayName       = $DisplayName
                    Mail              = $Mail
                    UserPrincipalName = $UserPrincipalName
                    Folder            = $Folder.DisplayName
                    ChildFolderCount  = $Child.ChildFolderCount
                    unreadItemCount   = $Child.unreaditemCount
                    totalItemCount    = $Child.unreaditemCount
                    wellKnownName     = $Child.wellKnownName
                    ParentFolderId    = $Child.ParentFolderId
                    Id                = $Child.Id
                }
                if ($Child.ChildFolderCount -ge 1) {
                    $ChildSplat = @{
                        DisplayName       = $UPN.DisplayName
                        Mail              = $UPN.Mail
                        UserPrincipalName = $UPN.UserPrincipalName
                    }
                    $Child | Get-GraphMailFolderChild @ChildSplat
                }
            }
        }
    }
}
