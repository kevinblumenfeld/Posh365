function Get-GitHubGist {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Username,

        [Parameter(Mandatory)]
        [string]
        $Filename
    )
    $Id = Get-GitHubGistID -Username $Username -Filename $Filename
    $Params = @{
        Uri    = "https://api.github.com/gists/$Id"
        Method = 'Get'
    }
    (Invoke-RestMethod @Params).files.${Filename}
}