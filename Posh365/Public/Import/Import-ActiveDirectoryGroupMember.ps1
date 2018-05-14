function Import-ActiveDirectoryGroupMember { 
    <#
    .SYNOPSIS
    Import Active Directory Group Members
    
    .DESCRIPTION
    Import Active Directory Group Members
    
    .PARAMETER Groups
    CSV of new AD Groups and Member
    
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
        $Log = Join-Path $OutputPath ($LogFileName + "-WhatIf_Import.csv")
        $ErrorLog = Join-Path $OutputPath ($LogFileName + "-Error_Log.csv")
    
        
        $DomainNameHash = Get-DomainNameHash

        Write-Verbose "Importing Active Directory Users that have at least one proxy address"
        $AllADUsers = Get-ADUGroupsWithProxyAddress -DomainNameHash $DomainNameHash

        Write-Verbose "Caching hash table. DisplayName attribute as key and value of ObjectGuid"
        $ADHashMailToGuid = $AllADUsers | Get-ADHashMailToGuid
    }
    Process {
        ForEach ($CurGroup in $Groups) {
            $setparams = @{}
            ForEach ($h in $sethash.keys) {
                if ($($sethash.item($h))) {
                    $setparams.add($h, $($sethash.item($h)))
                }
            }

            $filter = '{0} -eq {1}' -f $CurGroup.DisplayName
            $Group = Get-ADGroup -filter $filter

            if ($CurGroup.MembersSMTP) {
                $CurGroup.MembersSMTP -Split ";" | ForEach-Object {
                    Set-DistributionGroup -Identity $Group.ObjectGuid -ManagedBy @{Add = "$ADHashMailToGuid[$_]"}
                }
            }
            Set-ADGroup -identity $Group.ObjectGUID 
        }
    }
    End {
        
    }
}
