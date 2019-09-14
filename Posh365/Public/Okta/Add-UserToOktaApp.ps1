function Add-UserToOktaApp {
    <#
    .SYNOPSIS
    Add user to Okta app

    .DESCRIPTION
    Add user to Okta app

    .PARAMETER Login
    Users Okta Login

    .PARAMETER AppId
    The application id as assigned by Okta

    .EXAMPLE
    'user@contoso.com' | Add-UserToOktaApp -AppID '0oa2wf5crfrL9dEpJ234' -Verbose

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
        Write-Verbose "Attemting to Add $Login to $AppId"
        $ID = (Get-SingleOktaUserReport -Login $Login).ID
        $Headers = @{
            "Authorization" = "SSWS $Token"
            "Accept"        = "application/json"
            "Content-Type"  = "application/json"
        }
        $RestSplat = @{
            Uri     = "https://$Url.okta.com/api/v1/apps/{0}/users" -f $AppId
            Headers = $Headers
            Method  = 'POST'
        }
        $Body = @{
            "id"          = $ID
            "scope"       = "USER"
            "credentials" = @{
                "userName" = $Login
            }
        }
        $Response = Invoke-RestMethod @RestSplat -Body ($Body | ConvertTo-Json)
        $Response.Headers
    }
}
