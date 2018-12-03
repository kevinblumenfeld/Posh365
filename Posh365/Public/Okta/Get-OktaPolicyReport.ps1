function Get-OktaPolicyReport {

    Param (

    )
    $Url = $OKTACredential.GetNetworkCredential().username
    $Token = $OKTACredential.GetNetworkCredential().Password

    $Headers = @{
        "Authorization" = "SSWS $Token"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    }
    $PolicyType = 'OKTA_SIGN_ON', 'PASSWORD', 'MFA_ENROLL', 'OAUTH_AUTHORIZATION_POLICY'

    foreach ($CurPolicyType in $PolicyType) {
        $RestSplat = @{
            Uri     = "https://$Url.okta.com/api/v1/policies?type=$CurPolicyType"
            Headers = $Headers
            Method  = 'Get'
        }

        try {
            $Policy = Invoke-RestMethod @RestSplat -ErrorAction Stop
        }
        catch {
            continue
        }

        foreach ($CurPolicy in $Policy) {
            $Groups = (($CurPolicy).conditions.people.groups.include | ForEach-Object {
                    ((Get-OktaGroupReport $_).name) -join ";"
                })

            [PSCustomObject]@{
                Name        = $CurPolicy.Name
                Type        = $CurPolicy.Type
                Priority    = $CurPolicy.Priority
                Id          = $CurPolicy.Id
                Status      = $CurPolicy.Status
                Description = $CurPolicy.Description
                Groups      = $Groups
            }

        }
    }
}
