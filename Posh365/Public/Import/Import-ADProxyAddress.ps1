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
Import-Csv .\CSVofADUsers.csv | Import-ADProxyAddress -caseMatchAnd "brann" -MatchNotAnd @("JAIME","John") -JoinType and

.EXAMPLE
Import-Csv .\CSVofADUsers.csv | Import-ADProxyAddress -caseMatchAnd "Harry Franklin" -MatchNotAnd @("JAIME","John") -JoinType or

.NOTES
Input of ProxyAddresses are exptected to be semicolon seperated

#>
    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $Row,

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
        
        [Parameter()]
        [Switch]$WhatIf
    )
    Begin {
        $OutputPath = '.\'
        $LogFileName = ($(get-date -Format yyyy-MM-dd_HH-mm-ss) + "-DryRun.csv")
        $Log = Join-Path $OutputPath $LogFileName
        $Header = "DisplayName,EmailAdddresses"
        Out-File -FilePath $Log -InputObject $Header -Encoding UTF8 -append

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
        ForEach ($CurRow in $Row) {
            $address = ($CurRow.EmailAddresses -split ";" | 
                    Where-Object $filter) -join ","
            if (! $WhatIf) {
                
            }
            else {
                if ($address) {
                    "`"" + $CurRow.DisplayName + "`"" + "," + "`"" + $address + "`"" | Out-File -FilePath $Log -Encoding UTF8 -append
                }
            }
        }
    }
    End {

    }
}