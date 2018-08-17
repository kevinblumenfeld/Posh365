function Test-Uri {
    <#
    .SYNOPSIS
    Validates a given Uri
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    Param
    (
        # Uri to be validated
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [string]
        $UriString
    )

    [Uri]$uri = $UriString -as [Uri]
    $uri.AbsoluteUri -ne $null -and $uri.Scheme -eq 'https'
}