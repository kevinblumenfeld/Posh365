function Get-SPN {
    <#
    .SYNOPSIS
    Retrieves Server's SPNs

    .DESCRIPTION
    Retrieves Server's SPNs

    .EXAMPLE
    Get-SPN

    .NOTES
    Will soon add switches for different types of SPN groups
    #>
    param ()

    $search = New-Object DirectoryServices.DirectorySearcher([ADSI]"")
    $search.filter = "(&(objectcategory=computer)(OperatingSystem=*server*))"
    $search.filter = "(servicePrincipalName=*)"
    $results = $search.Findall()
    foreach ($result in $results) {
        $userEntry = $result.GetDirectoryEntry()
        foreach ($SPN in $userEntry.servicePrincipalName) {
            [PSCustomObject]@{
                Hostname = $userEntry.name
                SPN      = $SPN
            }
        } 
    }
}