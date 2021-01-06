function Get-ExDistributionGroupMember {

    <#

    .SYNOPSIS
    Get all members of all DGs, one per line

    .DESCRIPTION
    Get all members of all DGs, one per line

    .EXAMPLE
    Get-ExDistributionGroupMember | Export-Csv .\GroupMembers.csv -notypeinformation

    .EXAMPLE
    Get-ExDistributionGroupMember -verbose | Export-Csv .\GroupMembers.csv -notypeinformation

    .EXAMPLE
    # More specifically, feed the script a list of Distribution Groups - ensure GUID is a column
    Get-ExDistributionGroupMember -CsvFilePath .\DGs.csv | Export-Csv .\GroupMembers.csv -notypeinformation

    .NOTES
    General notes

    #>

    [CmdletBinding()]
    param (

        [Parameter()]
        [ValidateScript( { Test-Path $_ } )]
        $CsvFilePath
    )
    if ($CsvFilePath) {
        $GroupList = Import-Csv $CsvFilePath
    }
    else {
        $GroupList = Get-DistributionGroup -ResultSize Unlimited
    }
    $RecipientHash = Get-RecipientCNHash
    foreach ($Group in $GroupList) {

        $MemberList = Get-DistributionGroupMember -Identity $Group.Guid.toString()
        Write-Verbose "Distribution Group: $($Group.name)"

        $OwnerList = [System.Collections.Generic.List[string]]::New()

        if ($Group.ManagedBy) {

            @($Group.ManagedBy).ForEach{ $OwnerList.Add($RecipientHash[$_]) }
        }
        $ManagedBy = if ($OwnerList) {
            @($OwnerList) -ne '' -join '|'
        }
        else { '' }

        foreach ($Member in $MemberList) {
            [PSCustomObject]@{
                GroupName         = $Group.Name
                GroupPrimary      = $Group.PrimarySmtpAddress
                GroupType         = $Group.GroupType
                MemberName        = $Member.DisplayName
                MemberPrimary     = $Member.PrimarySmtpAddress
                MemberTypeDetails = $Member.RecipientTypeDetails
                ManagedBy         = $ManagedBy
            }
        }
    }
}
