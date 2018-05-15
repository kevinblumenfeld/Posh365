function New-ActiveDirectoryGroup { 
    <#
    .SYNOPSIS
    New Active Directory Group
    
    .DESCRIPTION
    New Active Directory Group
    
    .PARAMETER Groups
    CSV of new AD Groups and attributes to create.
    
    .EXAMPLE
    New-Csv .\Newgroups.csv | New-ActiveDirectoryGroup -Match contoso.com -JoinType or -OU "OU=Groups,OU=Synced,OU=CORP,DC=Contoso,DC=com"

    #>

    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $Group,
    
        [Parameter(Mandatory = $true)]
        [ValidateSet("and", "or")]
        [String]$JoinType,
    
        [Parameter()]
        [String[]]$Match,
    
        [Parameter()]
        [String[]]$caseMatch,
    
        [Parameter()]
        [String[]]$matchAnd,
    
        [Parameter()]
        [String[]]$caseMatchAnd,
    
        [Parameter()]
        [String[]]$MatchNot,
    
        [Parameter()]
        [String[]]$caseMatchNot,
            
        [Parameter()]
        [String[]]$MatchNotAnd,
    
        [Parameter()]
        [String[]]$caseMatchNotAnd,
            
        [Parameter(Mandatory = $true)]
        [String]$OU,
        
        [Parameter()]
        [string]$Domain,

        [Parameter()]
        [string]$NewDomain
    )
    Begin {
        if ($Domain -and (! $NewDomain)) {
            Write-Warning "Must use NewDomain parameter when specifying Domain parameter"
            break
        }
        if ($NewDomain -and (! $Domain)) {
            Write-Warning "Must use Domain parameter when specifying NewDomain parameter"
            break
        }
        Import-Module ActiveDirectory -Verbose:$False
        $OutputPath = '.\'
        $LogFileName = $(get-date -Format yyyy-MM-dd_HH-mm-ss)
        $Log = Join-Path $OutputPath ($LogFileName + "-WhatIf_Import.csv")
        $ErrorLog = Join-Path $OutputPath ($LogFileName + "-Error_Log.csv")
    
        $filterElements = $psboundparameters.Keys | Where-Object { $_ -match 'Match' } | ForEach-Object {
    
            if ($_.EndsWith('And')) {
                $logicOperator = ' -and '
            }
            else {
                $logicOperator = ' -or '
            }
                
            $comparisonOperator = switch ($_) {
                { $_.StartsWith('case') } { '-cmatch' }
                default { '-match' }
            }
    
            if ($_.Contains('Not')) {
                $comparisonOperator = $comparisonOperator -replace '^-(c?)', '-$1not'
            }
    
            $elements = foreach ($value in $psboundparameters[$_]) {
                '$_ {0} "{1}"' -f $comparisonOperator, $value
            }
            $elements -join $logicOperator
        }
        $filterString = '({0})' -f ($filterElements -join (') -{0} (' -f $JoinType))
        $filter = [ScriptBlock]::Create($filterString)
        Write-Verbose "Filter being used: $filter"

    }
    Process {
        ForEach ($CurGroup in $Group) {            

            $newGroup = @{
                DisplayName   = $CurGroup.DisplayName
                Name          = $CurGroup.Name
                GroupCategory = "Distribution"
                GroupScope    = "Universal"
                Path          = $OU
            }            
            $HashNulls = $newGroup.GetEnumerator() | Where-Object {
                $_.Value -eq $null 
            }
            $HashNulls | ForEach-Object {
                $newGroup.remove($_.key)
            }

            New-ADGroup @newGroup

            $ADFilter = 'DisplayName -eq "{0}"' -f $CurGroup.DisplayName
            $ADGroup = Get-ADGroup -filter $ADFilter
            $distinguishedName = $null
            $distinguishedName = $ADGroup.distinguishedname

            if ($distinguishedName) {
                Rename-ADObject $distinguishedName -NewName $CurGroup.DisplayName
            }

            $PrimarySMTP = $CurGroup.EmailAddresses -split ";" | Where-Object {$_ -cmatch "SMTP:"}
            $PrimarySMTP = $PrimarySMTP.Substring(5)
            Set-ADGroup -Identity $ADGroup.ObjectGUID -Add @{Mail = $PrimarySMTP}
            $Address = $CurGroup.EmailAddresses -split ";" | Where-Object $filter
            if ($Domain) {
                $Address = $Address | ForEach-Object {
                    $_ -replace ([Regex]::Escape($Domain), $NewDomain)
                }
            }
            $Address | ForEach-Object {
                Set-ADGroup -Identity $ADGroup.ObjectGUID -Add @{ProxyAddresses = "$_"}
                Write-Verbose "$($CurGroup.Displayname) `t Set ProxyAddress $($_)"
            }
        }
    }
    End {
        
    }
}
