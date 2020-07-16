function Get-GitHubGist {
    <#
    .SYNOPSIS
    Returns all GISTs with the name you specify in a named GitHub account

    .DESCRIPTION
    Returns all GISTs with the name you specify in a named GitHub account

    .PARAMETER Username
    GitHub Username

    .PARAMETER Filename
    Name of the GIST name.  This is named by the user before saving the GIST.
    Github does not mandate that the names are unique.
    This functions returns each that match the filename specified with this parameter

    .EXAMPLE
    Get-GitHubGist kevinblumenfeld -FileName test.xml

    .EXAMPLE
    (Get-GitHubGist kevinblumenfeld -FileName test.xml)[0]
    the most recent GIST named test.xml

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Username,

        [Parameter(Mandatory)]
        [string]
        $Filename
    )
    $IdList = Get-GitHubGistID -Username $Username -Filename $Filename
    foreach ($Id in $IdList) {
        $Params = @{
            Uri    = "https://api.github.com/gists/${Id}"
            Method = 'Get'
        }
        (Invoke-RestMethod @Params).files.$Filename
    }
}
