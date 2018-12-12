function Import-ActiveDirectoryGroupMember {
    <#
.SYNOPSIS
Import Active Directory Group Members

.DESCRIPTION
Import Active Directory Group Members

.PARAMETER Groups
CSV of new AD Groups and Members

.EXAMPLE
Import-Csv .\GroupsAndMembers.csv | Import-ActiveDirectoryGroupMember

.NOTES
CSV Example (Group Display Names and Email addresses of members)
=== =======

Group, MembersSMTP
Group1, joe@contoso.com; fred@contoso.com; sara@contoso.com
Group2, diane@contoso.com; sam@contoso.com; naomi@contoso.com
#>

    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $GroupAndMembers
    )
    Begin {
        Import-Module ActiveDirectory -Verbose:$False
        $OutputPath = '.\'
        $LogFileName = $(get-date -Format yyyy-MM-dd_HH-mm-ss)
        $ErrorLog = Join-Path $OutputPath ($LogFileName + "-Adding_Members_To_Groups_Error_Log.csv")

        $DomainNameHash = Get-DomainNameHash

        Write-Verbose "Importing Active Directory Objects that have at least one proxy address"
        $AllADObjects = Get-ADUsersAndGroupsWithProxyAddress -DomainNameHash $DomainNameHash

        Write-Verbose "Caching hash table. Mail attribute as key and value of ObjectGuid"
        $ADHashMailToGuid = $AllADObjects | Get-ADHashMailToGuid -erroraction silentlycontinue
    }
    Process {
        ForEach ($CurGroup in $GroupAndMembers) {
            try {
                $errorActionPreference = 'Stop'
                $Filter = {DisplayName -eq "{0}"} -f $CurGroup.DisplayName
                $Group = Get-ADGroup -filter $Filter
                Write-Verbose "Group: $($CurGroup.DisplayName)"
                if ($CurGroup.MembersSMTP) {
                    $CurGroup.MembersSMTP -Split ";" | ForEach-Object {
                        $EachMember = $_
                        Add-ADGroupMember -Identity $Group.ObjectGuid -Members $ADHashMailToGuid[$EachMember]
                        Write-Verbose "Member Added: $EachMember"
                    }
                }
            }
            catch {
                $ErrorMessage = $_.exception.message
                [PSCustomObject]@{
                    DisplayName = $CurGroup.DisplayName
                    Error       = $ErrorMessage
                    Member      = $EachMember
                    Members     = $CurGroup.MembersSMTP
                } | Export-Csv $ErrorLog -Append -NoTypeInformation -Encoding UTF8
            }
        }
    }
    End {

    }
}
