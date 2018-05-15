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

#>

    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $Groups
    )
    Begin {
        Import-Module ActiveDirectory -Verbose:$False
        $OutputPath = '.\'
        $LogFileName = $(get-date -Format yyyy-MM-dd_HH-mm-ss)
        $ErrorLog = Join-Path $OutputPath ($LogFileName + "-Error_Log.csv")

        $DomainNameHash = Get-DomainNameHash

        Write-Verbose "Importing Active Directory Objects that have at least one proxy address"
        $AllADObjects = Get-ADObjectWithProxyAddress -DomainNameHash $DomainNameHash

        Write-Verbose "Caching hash table. Mail attribute as key and value of ObjectGuid"
        $ADHashMailToGuid = $AllADObjects | Get-ADHashMailToGuid -erroraction silentlycontinue
    }
    Process {
        ForEach ($CurGroup in $Groups) {
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
                [PSCustomObject]@{
                    DisplayName = $Group.DisplayName
                    Error       = $_
                    Member      = $EachMember
                    Members     = $CurGroup.MembersSMTP
                } | Export-Csv $ErrorLog -Append -NoTypeInformation -Encoding UTF8
            }
        }
    }
    End {

    }
}
