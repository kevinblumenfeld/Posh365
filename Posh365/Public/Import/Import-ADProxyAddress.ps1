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
        [String[]]$MatchNotAnd,

        [Parameter()]
        [String[]]$caseMatchNotAnd
    )
    Begin {
        $filterElements = $psboundparameters.Keys | Where-Object { $_ -match 'Match' } | ForEach-Object {
            # Could do if
            if ($_.EndsWith('And')) {
                $logicOperator = ' -and '
            }
            else {
                $logicOperator = ' -or '
            }

            # Or switch
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
        Write-Verbose "Filter used: $filter"
    }
    Process {
        ForEach ($CurRow in $Row) {
            $CurRow.EmailAddresses -split ";" | 
                Where-Object $filter
        }
    }
    End {
        Write-Verbose "Filter used: $filter"
    }
}