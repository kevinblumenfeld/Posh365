function Get-GraphMailFolderPathId {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Tenant
    Parameter description

    .PARAMETER FolderPath
    Parameter description

    .PARAMETER User
    Parameter description

    .EXAMPLE
    Get-GraphUser -Tenant contoso -UserPrincipalName "joe@contoso.com" | Get-GraphMailFolderStructure -Tenant contoso -FolderPath "inbox\Sub1\Sub1"

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string] $Tenant,

        [Parameter()]
        $FolderPath,

        [Parameter(ValueFromPipeline)]
        $User

    )
    begin {
        Connect-PoshGraph -Tenant $Tenant
    }
    process {
        foreach ($CurUser in $User) {
            # $Token = Connect-PoshGraph -Tenant $Tenant
            # $DisplayName = $CurUser.DisplayName
            # $UPN = $CurUser.UserPrincipalName
            # $Mail = $CurUser.Mail
            $Id = $CurUser.Id

            $FolderArray = $FolderPath.Split("\")
            $FirstFolder = $FolderArray[0]
            $Headers = @{
                "Authorization" = "Bearer $Token"
            }
            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/beta/users/{0}/mailFolders('{1}')/childFolders" -f $Id, $FirstFolder
                Headers = $Headers
                Method  = 'Get'
            }
            for ($i = 1; $i -lt $FolderArray.Length; $i++) {
                $FolderName = $FolderArray[$i]
                $Response = Invoke-RestMethod @RestSplat -Verbose:$false -ErrorAction Stop
                $Folder = $Response.value
                $SubFolder = $Folder.where{$_.displayname -eq $FolderName}
                $FolderId = $SubFolder.Id.ToString()
                $RestSplat = @{
                    Uri     = "https://graph.microsoft.com/beta/users/{0}/mailFolders('{1}')/childFolders" -f $Id, $FolderId
                    Headers =  @{ "Authorization" = "Bearer $Token" }
                    Method  = 'Get'
                }
            }
            $FolderId
        }
    }
    end {

    }

}
