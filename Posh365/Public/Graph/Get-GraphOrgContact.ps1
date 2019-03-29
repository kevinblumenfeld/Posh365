function Get-GraphOrgContact {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string] $Tenant
    )
    begin {
        $SelectString = 'DisplayName, mail, id'
    }
    process {
        $Token = Connect-Graph -Tenant $Tenant
        $Headers = @{
            "Authorization" = "Bearer $Token"
        }
        $RestSplat = @{
            Uri     = 'https://graph.microsoft.com/beta/contacts?$select={0}' -f $SelectString
            Headers = $Headers
            Method  = 'Get'
        }
        do {
            $Response = Invoke-WebRequest @RestSplat -Verbose:$false
            $Headers = $Response.Headers
            $ObjList = $Response.Content | ConvertFrom-Json
            foreach ($Obj in $ObjList.Value) {
                [PSCustomObject]@{
                    DisplayName = $Obj.DisplayName
                    Mail        = $Obj.Mail
                    Id          = $Obj.Id
                }
            }
            if ($Response.Headers['link'] -match '<([^>]+?)>;\s*rel="next"') {
                $Next = $matches[1]
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
