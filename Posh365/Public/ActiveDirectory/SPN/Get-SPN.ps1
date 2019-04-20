function Get-SPN {
    <#
    .SYNOPSIS
    Retrieves all SPNs

    .DESCRIPTION
    Retrieves all SPNs

    .EXAMPLE
    Get-SPN

    .NOTES

    #>
    param ()

    $search = New-Object DirectoryServices.DirectorySearcher
    $search.filter = "(servicePrincipalName=*)"
    $null = $search.PropertiesToLoad.Add("Name")
    $null = $search.PropertiesToLoad.Add("servicePrincipalName")
    $null = $search.PropertiesToLoad.Add("objectClass")
    $null = $search.PropertiesToLoad.Add("DistinguishedName")
    $null = $search.PropertiesToLoad.Add("whencreated")
    $null = $search.PropertiesToLoad.Add("DNSHostName")
    $search.PageSize = 1000

    foreach ($result in $search.Findall()) {

        $ObjectClass = [regex]::match($result.Properties['objectClass'], '[^,\s]*$').captures.groups[0]
        $OrganizationalUnit = ($result.Properties['DistinguishedName'][0] -replace '^.+?,(?=(OU|CN)=)')
        $Name = $result.Properties['name'][0]
        $WhenCreated = $result.Properties['whencreated'][0]
        $DNSHostName = $result.Properties['DNSHostName'][0]

        foreach ($SPN in $result.Properties['servicePrincipalName']) {
            [PSCustomObject]@{
                Name               = $Name
                SPN                = $SPN
                ObjectClass        = $ObjectClass
                OrganizationalUnit = $OrganizationalUnit
                WhenCreated        = $WhenCreated
                DNSHostName        = $DNSHostName
            }
        }
    }
}
