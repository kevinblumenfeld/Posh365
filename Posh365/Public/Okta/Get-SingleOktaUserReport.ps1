function Get-SingleOktaUserReport {

    Param (
        [Parameter()]
        [string] $SearchString,

        [Parameter()]
        [string] $Filter,

        [Parameter()]
        [string] $Id,

        [Parameter()]
        [string] $Login
    )

    $Url = $OKTACredential.GetNetworkCredential().username
    $Token = $OKTACredential.GetNetworkCredential().Password

    $Headers = @{
        "Authorization" = "SSWS $Token"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    }

    if ($SearchString) {
        $RestSplat = @{
            Uri     = "https://$Url.okta.com/api/v1/users/?limit=200&q=$SearchString"
            Headers = $Headers
            Method  = 'Get'
        }
    }
    if ($Filter) {
        $RestSplat = @{
            Uri     = "https://$Url.okta.com/api/v1/users/?limit=200&filter=$Filter"
            Headers = $Headers
            Method  = 'Get'
        }
    }
    if ($Id) {
        $RestSplat = @{
            Uri     = 'https://{0}.okta.com/api/v1/users/?limit=200&filter=id eq "{1}"' -f $Url, $id
            Headers = $Headers
            Method  = 'Get'
        }
    }
    if ($Login) {
        $RestSplat = @{
            Uri     = "https://$Url.okta.com/api/v1/users/$Login"
            Headers = $Headers
            Method  = 'Get'
        }
    }
    $Response = Invoke-WebRequest @RestSplat -Verbose:$false
    $Headers = $Response.Headers
    $User = $Response.Content | ConvertFrom-Json
    $Headers = @{
        "Authorization" = "SSWS $Token"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    }
    $RestSplat = @{
        Uri     = $Next
        Headers = $Headers
        Method  = 'Get'
    }

    foreach ($CurUser in $User) {

        $Id = $CurUser.Id
        $ProfileDetail = ($CurUser).Profile
        $CredDetail = ($CurUser).Credentials

        [PSCustomObject]@{
            FirstName        = $ProfileDetail.FirstName
            LastName         = $ProfileDetail.LastName
            Login            = $ProfileDetail.Login
            Email            = $ProfileDetail.Email
            Id               = $Id
            ProviderType     = $CredDetail.Provider.Type
            ProviderName     = $CredDetail.Provider.Name
            Status           = $CurUser.Status
            Created          = $CurUser.Created
            Activated        = $CurUser.Activated
            StatusChanged    = $CurUser.StatusChanged
            LastLogin        = $CurUser.LastLogin
            LastUpdated      = $CurUser.LastUpdated
            PasswordChanged  = $CurUser.PasswordChanged
            RecoveryQuestion = $CredDetail.RecoveryQuestion.Question
        }
    }
}