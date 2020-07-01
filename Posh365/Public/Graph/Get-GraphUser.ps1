function Get-GraphUser {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string]
        $Tenant,

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
            ($Token = Connect-PoshGraph -Tenant $Tenant).access_token
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
                    $CurUser | Select *
                    # [PSCustomObject]@{
                    #     DisplayName       = $CurUser.DisplayName
                    #     UserPrincipalName = $CurUser.UserPrincipalName
                    #     Mail              = $CurUser.Mail
                    #     Id                = $CurUser.Id
                    #     OU                = $CurUser.onPremisesDistinguishedName -replace '^.+?,(?=(OU|CN)=)'
                    #     proxyAddresses    = ($CurUser.proxyAddresses | Where-Object {$_ -ne $null}) -join ";"
                    # }
                }
            }
            catch {
                Write-Host "$User - $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    end {

    }

}
