function Get-GraphMailEnabledUser {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string] $Tenant
    )
    begin {

    }
    process {
        $Token = Connect-Graph -Tenant $Tenant
        $Headers = @{
            "Authorization" = "Bearer $Token"
        }
        $RestSplat = @{
            Uri     = 'https://graph.microsoft.com/v1.0/users'
            Headers = $Headers
            Method  = 'Get'
        }
        do {
            $Response = Invoke-RestMethod @RestSplat -Verbose:$false
            $ObjList = $Response.Value
            foreach ($Obj in $ObjList) {
                [PSCustomObject]@{
                    DisplayName = $Obj.DisplayName
                    Mail        = $Obj.Mail
                    MobilePhone = $Obj.mobilePhone
                }
            }
            if ($Response.'@odata.nextLink') {
                $Next = $Response.'@odata.nextLink'
            }
            else {
                $Next = $null
            }
            $Headers = @{
                "Authorization" = "Bearer $Token"
            }
            $RestSplat = @{
                Uri     = $Next
                Headers = $Headers
                Method  = 'Get'
            }

        } until (-not $next)

    }
    end {

    }

}
