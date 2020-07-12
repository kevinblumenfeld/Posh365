function Get-GitHubGistID {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Username,

        [Parameter(Mandatory)]
        [string]
        $FileName
    )

    $Params = @{
        Uri    = 'https://api.github.com/users/{0}/gists' -f $Username
        method = 'Get'
    }
    $GistList = Invoke-RestMethod @Params
    foreach ($Gist in $GistList) {
        if ($Gist.files.${FileName}) {
            $Gist.ID
        }
    }
}
