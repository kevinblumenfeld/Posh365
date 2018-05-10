function Import-ADProxyAddress { 
    <#
.SYNOPSIS
Import ProxyAddresses into Active Directory

.DESCRIPTION
Import ProxyAddresses into Active Directory

.PARAMETER Row
Parameter description

.PARAMETER JoinType
Parameter description

.PARAMETER Match
Parameter description

.PARAMETER caseMatch
Parameter description

.PARAMETER matchAnd
Parameter description

.PARAMETER caseMatchAnd
Parameter description

.PARAMETER MatchNotAnd
Parameter description

.PARAMETER caseMatchNotAnd
Parameter description

.EXAMPLE
Import-Csv .\CSVofADUsers.csv | Import-ADProxyAddress -caseMatchAnd "brann" -MatchNotAnd @("JAIME") -JoinType and

.NOTES
Input of ProxyAddresses are exptected to be semicolon seperated

#>
    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $Row,
        [Parameter()]
        [ValidateSet("and", "or")]
        $JoinType,
        [Parameter()]
        $Match,
        [Parameter()]
        $caseMatch,
        [Parameter()]
        $matchAnd,
        [Parameter()]
        $caseMatchAnd,
        [Parameter()]
        $MatchNotAnd,
        [Parameter()]
        $caseMatchNotAnd
    )
    Begin {
        $filterElements = New-Object System.Collections.Generic.List[String]
        if ($Match) {
            $paramMatch = foreach ($curMatch in $Match) {
                '$_ -match "{0}"' -f $curMatch
            }
            $filterElements.Add($paramMatch -join " -or ")
        }
        if ($caseMatch) {
            $paramMatch = foreach ($curMatch in $caseMatch) {
                '$_ -cmatch "{0}"' -f $curMatch
            }
            $filterElements.Add($paramMatch -join " -or ")
        }
        if ($matchAnd) {
            $paramMatch = foreach ($curMatchAnd in $matchAnd) {
                '$_ -match "{0}"' -f $curMatchAnd
            }
            $filterElements.Add($paramMatch -join " -and ")
        }
        if ($caseMatchAnd) {
            $paramMatch = foreach ($curcaseMatchAnd in $caseMatchAnd) {
                '$_ -cmatch "{0}"' -f $curcaseMatchAnd
            }
            $filterElements.Add($paramMatch -join " -and ")
        }
        if ($matchNotAnd) {
            $paramMatch = foreach ($curMatchNotAnd in $matchNotAnd) {
                '$_ -notmatch "{0}"' -f $curMatchNotAnd
            }
            $filterElements.Add($paramMatch -join " -and ")
        }
        if ($caseMatchNotAnd) {
            $paramMatch = foreach ($curCaseMatchNotAnd in $caseMatchNotAnd) {
                '$_ -cnotmatch "{0}"' -f $curCaseMatchNotAnd
            }
            $filterElements.Add($paramMatch -join " -and ")
        }
        if ($JoinType -eq 'and') {
            $filterString = '(' + ($filterElements -join ') -and (') + ')'
        }
        else {
            $filterString = '(' + ($filterElements -join ') -or (') + ')'
        }
        
        $filter = [ScriptBlock]::Create($filterString)
        write-host $filter
    }
    Process {
        ForEach ($CurRow in $Row) {
            $CurRow.EmailAddresses -split ";" | 
                Where-Object $filter
        }
    }
    End {

    }
}

