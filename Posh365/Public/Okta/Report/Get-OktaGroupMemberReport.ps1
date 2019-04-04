function Get-OktaGroupMemberReport {
    <#
    .SYNOPSIS
        Searches for specific or all Okta Groups and lists their members

    .DESCRIPTION
        Searches for specific or all Okta Groups and lists their members.  Use no parameters to return all Groups. e.g Get-OktaGroupMemberReport

    .PARAMETER SearchString
        Searches for groups by name in your organization and and lists their members
        Search currently performs a startsWith match but it should be considered an implementation detail
        and may change without notice in the future. Exact matches will always be returned before partial matches

    .PARAMETER GroupName
        Searches for groups by exact name

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
        Get-OktaGroupMemberReport | Export-Csv .\OktaGroups.csv -notypeinformation -Encoding UTF8

    .EXAMPLE
        Get-OktaGroupMemberReport -Filter 'type eq "BUILT_IN"'

    .EXAMPLE
        Get-OktaGroupMemberReport -GroupName 'Accounting'

    .EXAMPLE
        Get-OktaGroupMemberReport -Id 00u4m2pk9NMihnsWJ356
    #>
    [CmdletBinding(DefaultParameterSetName = 'Id')]
    Param (
        [Parameter(ParameterSetName = "SearchString")]
        [string] $SearchString,

        [Parameter(ParameterSetName = "GroupName")]
        [string] $GroupName,

        [Parameter(ParameterSetName = "Filter")]
        [string] $Filter,

        [Parameter(ParameterSetName = "Id")]
        [string] $Id
    )


    $Url = $OKTACredential.GetNetworkCredential().username
    $Token = $OKTACredential.GetNetworkCredential().Password

    $Headers = @{
        "Authorization" = "SSWS $Token"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    }

    if (-not $SearchString -and -not $id -and -not $Filter -and -not $GroupName) {
        $RestSplat = @{
            Uri     = "https://$Url.okta.com/api/v1/groups/?limit=200"
            Headers = $Headers
            Method  = 'Get'
        }

    }
    else {
        if ($GroupName) {
            $GroupId = (Get-OktaGroupReport | Where-Object { $_.Name -eq $GroupName }).id
            foreach ($CurGroupId in $GroupId) {
                Get-OktaGroupMemberReport -id $CurGroupId
            }
            return
        }
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
        [int]$NumberLimit = $Response.Headers.'x-rate-limit-remaining'
        [long][string]$UnixTime = $Response.Headers.'x-rate-limit-reset'

        if ($NumberLimit -and $NumberLimit -eq 1) {
            $ApiTime = $Response.Headers.'Date'
            $SleepTime = Convert-OktaRateLimitToSleep -UnixTime $UnixTime -ApiTime $ApiTime
            Start-Sleep -Seconds $SleepTime
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

            $CurGroupProfile = $CurGroup.Profile
            Start-Sleep -Milliseconds 100
            $Member = Get-OktaGroupMembership -GroupId $CurGroup.Id

            foreach ($CurMember in $Member) {
                [PSCustomObject]@{
                    MemberLogin                = $CurMember.Login
                    MemberFirstName            = $CurMember.FirstName
                    MemberLastName             = $CurMember.LastName
                    Name                       = $CurGroupProfile.Name
                    Description                = $CurGroupProfile.Description
                    Type                       = $CurGroup.Type
                    windowsDomainQualifiedName = $CurGroupProfile.windowsDomainQualifiedName
                    GroupType                  = $CurGroupProfile.GroupType
                    GroupScope                 = $CurGroupProfile.GroupScope
                    Id                         = $CurGroup.Id
                }
            }
        }
    } until (-not $next)
}
