function Get-ExDistributionGroupOwner {

    <#

    .SYNOPSIS
    Get DG owners, one per line in CN format

    .DESCRIPTION
    Get DG owners (ManagedBy), one per line in CN format

    .PARAMETER CSVPath
    The path to csv from Get-ExDistributionGroupMember
    The second .EXAMPLE shows the usage.

    .EXAMPLE
    Get-ExDistributionGroupOwner -CsvFilePath .\GroupMembers.csv | Export-Csv .\Owners.csv -notypeinformation

    .EXAMPLE
    Get-ExDistributionGroupMember | Export-Csv .\GroupMembers.csv -notypeinformation
    Get-ExDistributionGroupOwner -CsvFilePath .\GroupMembers.csv | Export-Csv .\Owners.csv -notypeinformation

    .NOTES
    Should you ever need to use the output to set Owners

    $ItemList = Import-Csv .\Owners.csv

    foreach ($Item in $ItemList) {
        Set-DistributionGroup -Identity $Item.GroupName -ManagedBy @{Add = $Item.OwnerName }
    }

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path $_ } )]
        $CsvFilePath
    )

    $GroupMemberList = Import-Csv $CsvFilePath

    $UniqueGroupList = $GroupMemberList | Group-Object -Property GroupPrimary | Select-Object @(
        'Name'
        @{
            name       = 'Owner'
            expression = { ($_.Group | Select-Object -ExpandProperty ManagedBy).split('|') }
        }
    )

    foreach ($Group in $UniqueGroupList) {
        foreach ($Owner in $Group.Owner) {
            [pscustomobject]@{
                GroupName = $Group.Name
                OwnerName = $Owner.split("/")[-1]
            }
        }
    }
}
