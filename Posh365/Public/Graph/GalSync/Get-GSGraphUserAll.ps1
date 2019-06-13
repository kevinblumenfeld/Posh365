function Get-GSGraphUserAll {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Tenant
    )
    begin {
        $Token = Connect-Graph -Tenant $Tenant

        $Headers = @{
            "Authorization" = "Bearer $Token"
        }
        $RestSplat = @{
            Uri     = 'https://graph.microsoft.com/beta/users'
            Headers = $Headers
            Method  = 'Get'
        }
        do {
            $Token = Connect-Graph -Tenant $Tenant
            try {
                $Response = Invoke-RestMethod @RestSplat -Verbose:$false -ErrorAction Stop
                $UserList = $Response.value
                if ($Response.'@odata.nextLink' -match 'skip') {
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
                foreach ($User in $UserList) {
                    $User | Select-Object *
                }
            }
            catch {
                $ErrorMessage = $_.Exception.Message
                Write-Host $User
                Write-Host $ErrorMessage
            }
        } until (-not $next)
    }
    process {

    }
    end {

    }

}
