function Remove-OktaUserfromApp {
    <#
        .SYNOPSIS
            Searches for specific Okta Users and removes (and deprovisions them) from a specific app

        .DESCRIPTION
            Searches for specific Okta Users and removes (and deprovisions them) from a specific app

        .EXAMPLE
            Remove-OktaUserfromApp -AppID 00u4m2pk9NMihnsWJ356 -ID 00d4em2pk9NMehesWJe3

        .EXAMPLE
            (Get-OktaAppUserReport -AppID 0oa497tfeAPQSU5sw356).id | Remove-OktaUserfromApp -AppID 0oa497tfeAPQSU5sw356

        #>
    Param (

        [Parameter(Mandatory)]
        [string] $AppID,

        [Parameter(ValueFromPipeline, Mandatory)]
        $Id

    )

    $Url = $OKTACredential.GetNetworkCredential().username
    $Token = $OKTACredential.GetNetworkCredential().Password

    $Headers = @{
        "Authorization" = "SSWS $Token"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    }

    $RestSplat = @{
        Uri     = 'https://{0}.okta.com/api/v1/apps/{1}/users/{2}?sendEmail=true' -f $Url, $AppID, $Id
        Headers = $Headers
        Method  = 'DELETE'
    }
    $Response = Invoke-WebRequest @RestSplat -Verbose:$false
}
