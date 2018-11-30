function Get-OktaUserReport {
    <#
        .SYNOPSIS
            Searches for specific or all Okta Users
    
        .DESCRIPTION
            Searches for specific or all Okta Users.  Use no parameters to return all users. e.g Get-OktaUserReport
    
        .PARAMETER SearchString
            Queries firstName, lastName, and email for a match to the -SearchString value specified.
            Partial matches can be searched for.  For example, the search for "J" will Return users with the firstName Joe, John and lastName Hajib
        
        .PARAMETER ID
            Search by ID
        
        .PARAMETER Filter
            List Users with a Filter
            Filters against the most up-to-date data. For example, if you create a user or change an attribute and then issue a filter request, the changes are reflected in your results.
            Requires URL encoding. For example, filter=lastUpdated gt "2013-06-01T00:00:00.000Z" is encoded as filter=lastUpdated%20gt%20%222013-06-01T00:00:00.000Z%22. 
            Examples use cURL-style escaping instead of URL encoding to make them easier to read.
    
            Supports only a limited number of properties: status, lastUpdated, id, profile.login, profile.email, profile.firstName, and profile.lastName.
    
            Filter	Description
            status eq "STAGED"	Users that have a status of STAGED
            status eq "PROVISIONED"	Users that have a status of PROVISIONED
            status eq "ACTIVE"	Users that have a status of ACTIVE
            status eq "RECOVERY"	Users that have a status of RECOVERY
            status eq "PASSWORD_EXPIRED"	Users that have a status of PASSWORD_EXPIRED
            status eq "LOCKED_OUT"	Users that have a status of LOCKED_OUT
            status eq "DEPROVISIONED"	Users that have a status of DEPROVISIONED
            lastUpdated lt "yyyy-MM-dd'T'HH:mm:ss.SSSZ"	Users last updated before a specific timestamp
            lastUpdated eq "yyyy-MM-dd'T'HH:mm:ss.SSSZ"	Users last updated at a specific timestamp
            lastUpdated gt "yyyy-MM-dd'T'HH:mm:ss.SSSZ"	Users last updated after a specific timestamp
            id eq "00u1ero7vZFVEIYLWPBN"	Users with a specified id
            profile.login eq "login@example.com"	Users with a specified login
            profile.email eq "email@example.com"	Users with a specified email*
            profile.firstName eq "John"	Users with a specified firstName*
            profile.lastName eq "Smith"	Users with a specified lastName*
    
        .EXAMPLE
            Get-OktaUserReport

        .EXAMPLE
            Get-OktaUserReport -Filter 'profile.firstName eq "Jennifer"'
    
        .EXAMPLE
            Get-OktaUserReport -SearchString kevin
        
        .EXAMPLE
            Get-OktaUserReport -Id 00u4m2pk9NMihnsWJ356
    
        #>
    Param (
        [Parameter()]
        [string] $SearchString,
            
        [Parameter()]
        [string] $Filter,

        [Parameter()]
        [string] $Id
    )
    
    if ($SearchString -and $filter -or ($SearchString -and $Id) -or ($Filter -and $Id)) {
        Write-Warning "Choose between zero and one parameters only"
        Write-Warning "Please try again"
        break
    }
    
    $Url = $OKTACredential.GetNetworkCredential().username
    $Token = $OKTACredential.GetNetworkCredential().Password
    
    $Headers = @{
        "Authorization" = "SSWS $Token"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    }

    if (-not $SearchString -and -not $id -and -not $Filter) {
        $RestSplat = @{
            Uri     = "https://$Url.okta.com/api/v1/users/?limit=200"
            Headers = $Headers
            Method  = 'Get'
        }
    
    }
    else {
        if ($SearchString) {
            $RestSplat = @{
                Uri     = "https://$Url.okta.com/api/v1/users/?limit=200&q=$SearchString"
                Headers = $Headers
                Method  = 'Get'
            }
        }    
        if ($Filter) {
            $RestSplat = @{
                Uri     = "https://$Url.okta.com/api/v1/users/?limit=200&filter=$Filter"
                Headers = $Headers
                Method  = 'Get'
            }
        }
        if ($Id) {
            $RestSplat = @{
                Uri     = 'https://{0}.okta.com/api/v1/users/?limit=200&filter=id eq "{1}"' -f $Url, $id
                Headers = $Headers
                Method  = 'Get'
            }
        }
    }

    do {

        if (($Response.Headers.'x-rate-limit-remaining' -lt 50) -and ($Response.Headers.'x-rate-limit-remaining')) {
            Start-Sleep -Seconds 4
        }
        $Response = Invoke-WebRequest @RestSplat
        $Headers = $Response.Headers
        $User = $Response.Content | ConvertFrom-Json 
        
        if ($Response.Headers['link'] -match '<([^>]+?)>;\s*rel="next"') {
            $Next = $matches[1]
        }
        else {
            $Next = $null
        }
        $Headers = @{
            "Authorization" = "SSWS $Token"
            "Accept"        = "application/json"
            "Content-Type"  = "application/json"
        }
        $RestSplat = @{
            Uri     = $Next
            Headers = $Headers
            Method  = 'Get'
        }
        
        foreach ($CurUser in $User) {
    
            $Id = $CurUser.Id
            $ProfileDetail = ($CurUser).Profile
            $CredDetail = ($CurUser).Credentials
    
            [PSCustomObject]@{
                FirstName        = $ProfileDetail.FirstName
                LastName         = $ProfileDetail.LastName
                Login            = $ProfileDetail.Login
                Email            = $ProfileDetail.Email
                Id               = $Id
                ProviderType     = $CredDetail.Provider.Type
                ProviderName     = $CredDetail.Provider.Name
                Status           = $CurUser.Status
                Created          = $CurUser.Created
                Activated        = $CurUser.Activated
                StatusChanged    = $CurUser.StatusChanged
                LastLogin        = $CurUser.LastLogin
                LastUpdated      = $CurUser.LastUpdated
                PasswordChanged  = $CurUser.PasswordChanged
                RecoveryQuestion = $CredDetail.RecoveryQuestion.Question
            }
    
        }
    } until (-not $next)
}