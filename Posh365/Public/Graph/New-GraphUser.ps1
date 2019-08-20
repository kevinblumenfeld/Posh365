function New-GraphUser {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string] $Tenant,

        [Parameter(ValueFromPipeline)]
        $UserList
    )
    begin {
    }
    process {
        foreach ($User in $UserList) {
            $Token = Connect-Graph -Tenant $Tenant
            $Headers = @{
                'Authorization' = "Bearer $Token"
                'Content-Type'  = 'application/json'
            }

            $test = @{
                'accountEnabled'    = $true
                'mailnickname'      = ''
                'userPrincipalName' = ''
                'displayName'       = ''
                'passwordProfile'   = @{
                    'password'                      = ''
                    'forceChangePasswordNextSignIn' = $true
                }
            }


            $RestSplat = @{
                Uri     = 'https://graph.microsoft.com/v1.0/users'
                Headers = $Headers
                Method  = 'POST'
                Body    = ($test | ConvertTo-Json)
            }
            try {
                Invoke-RestMethod @RestSplat -Verbose:$true -ErrorAction Stop
            }
            catch {
                $_.Exception.Message
            }
        }
    }
    end {

    }

}
