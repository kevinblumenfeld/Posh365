function Get-OktaGroupReport {
    <#
    .SYNOPSIS
        Searches for specific or all Okta Groups

    .DESCRIPTION
        Searches for specific or all Okta Groups.  Use no parameters to return all Groups. e.g Get-OktaGroupReport

    .PARAMETER SearchString
        Searches for groups by name in your organization.
        Search currently performs a startsWith match but it should be considered an implementation detail
        and may change without notice in the future. Exact matches will always be returned before partial matches

    .PARAMETER ID
        Search by Group ID

    .PARAMETER Filter
        List Groups with a Filter
        Filters against the most up-to-date data. For example, if you create a user or change an attribute and then issue a filter request, the changes are reflected in your results.
        Requires URL encoding. For example, filter=lastUpdated gt "2013-06-01T00:00:00.000Z" is encoded as filter=lastUpdated%20gt%20%222013-06-01T00:00:00.000Z%22.
        Examples use cURL-style escaping instead of URL encoding to make them easier to read.

        Filter	                                                Description
        type eq "OKTA_GROUP"	                                Groups that have a type of OKTA_GROUP
        type eq "APP_GROUP"	                                    Groups that have a type of APP_GROUP
        type eq "BUILT_IN"	                                    Groups that have a type of BUILT_IN
        lastUpdated lt "yyyy-MM-dd'T'HH:mm:ss.SSSZ"	            Groups with profile last updated before a specific timestamp
        lastUpdated eq "yyyy-MM-dd'T'HH:mm:ss.SSSZ"	            Groups with profile last updated at a specific timestamp
        lastUpdated gt "yyyy-MM-dd'T'HH:mm:ss.SSSZ"	            Groups with profile last updated after a specific timestamp
        lastMembershipUpdated lt "yyyy-MM-dd'T'HH:mm:ss.SSSZ"	Groups with memberships last updated before a specific timestamp
        lastMembershipUpdated eq "yyyy-MM-dd'T'HH:mm:ss.SSSZ"	Groups with memberships last updated at a specific timestamp
        lastMembershipUpdated gt "yyyy-MM-dd'T'HH:mm:ss.SSSZ"	Groups with memberships last updated after a specific timestamp
        id eq "00g1emaKYZTWRYYRRTSK"	                        Group with a specified id

    .EXAMPLE
        Get-OktaGroupReport | Export-Csv .\OktaGroups.csv -notypeinformation -Encoding UTF8

    .EXAMPLE
        Get-OktaGroupReport -filter 'profile.name eq "Accounting"'

    .EXAMPLE
        Get-OktaGroupReport -Id 00u4m2pk9NMihnsWJ356
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
            Uri     = "https://$Url.okta.com/api/v1/groups/?limit=200"
            Headers = $Headers
            Method  = 'Get'
        }

    }
    else {
        if ($SearchString) {
            $RestSplat = @{
                Uri     = "https://$Url.okta.com/api/v1/groups/?limit=200&q=$SearchString"
                Headers = $Headers
                Method  = 'Get'
            }
        }
        if ($Filter) {
            $RestSplat = @{
                Uri     = "https://$Url.okta.com/api/v1/groups/?limit=200&filter=$Filter"
                Headers = $Headers
                Method  = 'Get'
            }
        }
        if ($Id) {
            $RestSplat = @{
                Uri     = 'https://{0}.okta.com/api/v1/groups/?limit=200&filter=id eq "{1}"' -f $Url, $id
                Headers = $Headers
                Method  = 'Get'
            }
        }
    }

    do {
        if (($Response.Headers.'x-rate-limit-remaining') -and ($Response.Headers.'x-rate-limit-remaining' -lt 50)) {
            Start-Sleep -Seconds 4
        }
        $Response = Invoke-WebRequest @RestSplat -Verbose:$false
        $Headers = $Response.Headers
        $Group = $Response.Content | ConvertFrom-Json
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

        foreach ($CurGroup in $Group) {

            $ProfileDetail = $CurGroup.Profile

            [PSCustomObject]@{
                Name                       = $ProfileDetail.Name
                Description                = $ProfileDetail.Description
                Type                       = $CurGroup.Type
                windowsDomainQualifiedName = $ProfileDetail.windowsDomainQualifiedName
                GroupType                  = $ProfileDetail.GroupType
                GroupScope                 = $ProfileDetail.GroupScope
                samAccountName             = $ProfileDetail.samAccountName
                DistinguishedName          = $ProfileDetail.DistinguishedName
                Id                         = $CurGroup.Id
                Created                    = $CurGroup.Created
                LastUpdated                = $CurGroup.LastUpdated
                LastMembershipUpdated      = $CurGroup.LastMembershipUpdated
            }
        }
    } until (-not $next)
}
