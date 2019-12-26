function Get-DomainFederationDataFromO365 {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainName
    )
    try {
        $uri = "https://login.microsoftonline.com/common/userrealm/?user=testuser@$DomainName&api-version=2.1&checkForMicrosoftAccount=true"

        Invoke-RestMethod -Uri $uri -ErrorAction Stop

    }
    catch {
        Write-Verbose "Couldn't retrieve federation data for domain: $DomainName"
    }
}
