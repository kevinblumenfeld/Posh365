function Get-GraphUser {
    [CmdletBinding(DefaultParameterSetName = 'NoFilter')]
    param (

        [Parameter(Mandatory)]
        [string] $Tenant,

        [Parameter()]
        [string] $Mailbox
    )
    begin {

        $Token = Connect-Graph -Tenant $Tenant

        $Headers = @{
            "Authorization" = "Bearer $Token"
        }
        $RestSplat = @{
            Uri     = "https://graph.microsoft.com/v1.0/users"
            Headers = $Headers
            Method  = 'Get'
        }
        $Response = Invoke-WebRequest @RestSplat -Verbose:$false
        $Headers = $Response.Headers
        $User = ($Response.Content | ConvertFrom-Json).value
        foreach ($CurUser in $User) {

            [PSCustomObject]@{
                DisplayName       = $CurUser.DisplayName
                UserPrincipalName = $CurUser.UserPrincipalName
                Mail              = $CurUser.Mail
                Id                = $CurUser.Id
            }
        }
    }
    process {

    }
    end {

    }

}
