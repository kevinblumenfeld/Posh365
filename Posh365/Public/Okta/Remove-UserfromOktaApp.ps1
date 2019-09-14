function Remove-UserfromOktaApp {
    <#
    .SYNOPSIS
    Remove user from Okta app

    .DESCRIPTION
    Remove user from Okta app

    .PARAMETER Login
    the users login to Okta

    .PARAMETER AppId
    The value assigned to the application by Okta

    .EXAMPLE
    'user@contoso.com' | Remove-UserfromOktaApp -AppID '0oa2wf5crfrL9dEpJ234' -Verbose

    .NOTES
    General notes
    #>


    Param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [string] $Login,

        [Parameter(Mandatory)]
        [string] $AppId
    )
    begin {

        $Url = $OKTACredential.GetNetworkCredential().username
        $Token = $OKTACredential.GetNetworkCredential().Password

    }
    process {
        Write-Verbose "Attemting to remove $Login from $AppId"
        $Id = (Get-SingleOktaUserReport -Login $Login).Id
        $Headers = @{
            "Authorization" = "SSWS $Token"
            "Accept"        = "application/json"
            "Content-Type"  = "application/json"
        }
        $RestSplat = @{
            Uri     = "https://$Url.okta.com/api/v1/apps/{0}/users/{1}" -f $AppId, $Id
            Headers = $Headers
            Method  = 'DELETE'
        }
        $null = Invoke-WebRequest @RestSplat -Verbose:$false
    }
}
