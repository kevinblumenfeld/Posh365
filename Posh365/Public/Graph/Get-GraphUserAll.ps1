function Get-GraphUserAll {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Tenant
    )
    begin {
        $Token = Connect-PoshGraph -Tenant $Tenant

        $Headers = @{
            "Authorization" = "Bearer $Token"
        }
        $RestSplat = @{
            Uri     = 'https://graph.microsoft.com/beta/users'
            Headers = $Headers
            Method  = 'Get'
        }
        do {
            $Token = Connect-PoshGraph -Tenant $Tenant
            try {
                $Response = Invoke-RestMethod @RestSplat -Verbose:$false -ErrorAction Stop
                $User = $Response.value
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
                foreach ($CurUser in $User) {
                    [PSCustomObject]@{
                        DisplayName       = $CurUser.DisplayName
                        UserPrincipalName = $CurUser.UserPrincipalName
                        Mail              = $CurUser.Mail
                        Id                = $CurUser.Id
                    }
                }
            }
            catch {
                $ErrorMessage = $_.Exception.Message
                Write-Host $CurUser
                Write-Host $ErrorMessage
            }
        } until (-not $next)
    }
    process {

    }
    end {

    }

}
