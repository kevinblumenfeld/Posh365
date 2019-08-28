function Get-GraphUserContacts {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Tenant,

        [Parameter(Mandatory)]
        [string] $UserPrincipalName,

        [Parameter()]
        [string] $email
    )
    begin {
    }
    process {
        $Token = Connect-Graph -Tenant $Tenant
        $Headers = @{
            "Authorization" = "Bearer $Token"
        }

        $RestSplat = @{
            Uri     = "https://graph.microsoft.com/v1.0/users/{0}/contacts?$top=1000" -f $UserPrincipalName, $email
            Headers = $Headers
            Method  = 'Get'
        }
        $Response = Invoke-RestMethod @RestSplat -Verbose:$false
        $Response.value
    }
    end {
    }
}
