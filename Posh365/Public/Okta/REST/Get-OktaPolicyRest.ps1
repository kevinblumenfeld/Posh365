function Get-OktaPolicyRest {
    
    Param (

    )
    $url = $Credential.GetNetworkCredential().username
    $token = $Credential.GetNetworkCredential().Password

    $headers = @{
        "Authorization" = "SSWS $Token"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    }
    $PolicyType = 'OKTA_SIGN_ON', 'PASSWORD', 'MFA_ENROLL', 'OAUTH_AUTHORIZATION_POLICY'
    
    foreach ($CurPolicyType in $PolicyType) {
        $RestSplat = @{
            Uri     = "https://$URL.okta.com/api/v1/policies?type=$CurPolicyType"
            Headers = $headers
            method  = 'Get'
        }

        try {
            $Policy = Invoke-RestMethod @RestSplat -ErrorAction Stop
        }
        catch {
            continue
        }

        foreach ($CurPolicy in $Policy) {
            $Groups = (($CurPolicy).conditions.people.groups.include | ForEach-Object {
                    ((Get-OktaGroupRest $_).name) -join ";"
                })

            [PSCustomObject]@{
                Type        = $CurPolicy.Type
                Name        = $CurPolicy.Name
                Priority    = $CurPolicy.Priority
                Id          = $CurPolicy.Id
                Status      = $CurPolicy.Status
                Description = $CurPolicy.Description
                Groups      = $Groups
            }

        }

    }
}
