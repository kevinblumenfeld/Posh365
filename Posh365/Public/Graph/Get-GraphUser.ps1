function Get-GraphUser {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string] $Tenant,

        [Parameter(ValueFromPipeline)]
        $UserPrincipalName
    )
    begin {
        if (-not $UserPrincipalName) {
            $UserPrincipalName = (Get-GraphUserAll -Tenant $Tenant).Id
        }
    }
    process {
        foreach ($CurUserPrincipalName in $UserPrincipalName) {
            $Token = Connect-Graph -Tenant $Tenant
            $Headers = @{
                "Authorization" = "Bearer $Token"
            }
            $RestSplat = @{
                Uri     = 'https://graph.microsoft.com/beta/users/{0}' -f $CurUserPrincipalName
                Headers = $Headers
                Method  = 'Get'
            }
            try {
                $User = Invoke-RestMethod @RestSplat -Verbose:$false -ErrorAction Stop
                foreach ($CurUser in $User) {
                    [PSCustomObject]@{
                        DisplayName       = $CurUser.DisplayName
                        UserPrincipalName = $CurUser.UserPrincipalName
                        Mail              = $CurUser.Mail
                        Id                = $CurUser.Id
                        OU                = $CurUser.onPremisesDistinguishedName -replace '^.+?,(?=(OU|CN)=)'
                        proxyAddresses    = ($CurUser.proxyAddresses | Where-Object {$_ -ne $null}) -join ";"
                    }
                }
            }
            catch {
                $ErrorMessage = $_.Exception.Message
                Write-Host $CurUserPrincipalName
                Write-Host $ErrorMessage
            }
        }
    }
    end {

    }

}
