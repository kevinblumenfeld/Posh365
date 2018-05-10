function Import-ADProxyAddress { 
    <#
.SYNOPSIS
Import ProxyAddresses into Active Directory

.DESCRIPTION
Import ProxyAddresses into Active Directory

.PARAMETER Row
Parameter description

.EXAMPLE
Import-Csv .\CSVofADUsers.csv | Import-ADProxyAddress -Match @("SPO:","brann")

.NOTES
Input of ProxyAddresses are exptected to be semicolon seperated
#>
    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $Row,
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
        if ($Match) {
            $paramMatch = foreach ($curMatch in $Match) {
                '$_ -match "{0}"' -f $curMatch
            }
            $filter = [ScriptBlock]::Create($paramMatch -join " -or ")
        }
        if ($caseMatch) {
            $paramMatch = foreach ($curMatch in $caseMatch) {
                '$_ -cmatch "{0}"' -f $curMatch
            }
            $filter = [ScriptBlock]::Create($paramMatch -join " -or ")
        }
        if ($matchAnd) {
            $paramMatch = foreach ($curMatchAnd in $matchAnd) {
                '$_ -match "{0}"' -f $curMatchAnd
            }
            $filter = [ScriptBlock]::Create($paramMatch -join " -and ")
        }
        if ($caseMatchAnd) {
            $paramMatch = foreach ($curcaseMatchAnd in $caseMatchAnd) {
                '$_ -cmatch "{0}"' -f $curcaseMatchAnd
            }
            $filter = [ScriptBlock]::Create($paramMatch -join " -and ")
        }
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
# Import-Csv "C:\Scripts\contoso-EXOMailbox_Detailed.csv" | Import-ADProxyAddress -caseMatch @("SPO:","SMTP:") -Match "onmicrosoft.com" -caseMatchAnd @("brann","jsltechinc.com")
