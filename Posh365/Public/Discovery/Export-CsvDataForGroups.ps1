function Export-CsvDataforGroups { 
    <#
.SYNOPSIS
Export ProxyAddresses from a CSV and output one per line.  Filtering if desired.  Automatically a csv will be exported.

.DESCRIPTION
Export ProxyAddresses from a CSV and output one per line.  Filtering if desired.  Automatically a csv will be exported.

.PARAMETER Row
Parameter description

.PARAMETER JoinType
Parameter description

.PARAMETER Match
This matches one or more items when looking at email addresses.  This uses the logic operator OR.
For example -Match @("smtp:","onmicrosoft.com") means it will find all attributes that match smtp: OR onmicrosoft.com

.PARAMETER caseMatch
Same as Match parameter but case sensitive

.PARAMETER matchAnd
The same as Match parameter but uses the AND logic operator

.PARAMETER caseMatchAnd
The same as matchAnd parameter but case sensitive

.PARAMETER MatchNot
The same as Match but with the comparison operator of NOT.  Uses logic operator of OR.
For example -MatchNot @("smtp:","onmicrosoft.com") means it will find all attributes that DO NOT MATCH smtp: OR onmicrosoft.com

.PARAMETER caseMatchNot
The same as MatchNot but case sensitive

.PARAMETER MatchNotAnd
The same as MatchNot but with the logic operator of AND.

.PARAMETER caseMatchNotAnd
The same as MatchNotAnd but case sensitive

.PARAMETER Domain
Parameter description

.PARAMETER NewDomain
Parameter description

.EXAMPLE
Import-Csv .\CSVofADUsers.csv | Export-CsvData -caseMatchAnd "brann" -MatchNotAnd @("JAIME","John") -JoinType and

.EXAMPLE
Import-Csv .\CSVofADUsers.csv | Export-CsvData -caseMatchAnd "Harry Franklin" -MatchNotAnd @("JAIME","John") -JoinType or

.NOTES
Input (from the CSV) of the Addresses (to be imported into ProxyAddresses attribute in Active Directory) are expected to be semicolon separated.

#>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (

        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $Row,

        [Parameter(Mandatory = $true)]
        [ValidateSet("and", "or")]
        [String]$JoinType,

        [Parameter(Mandatory = $true)]
        [ValidateSet("ProxyAddresses", "EmailAddresses", "x500", "MembersName")]
        [String]$FindAddressInColumn,

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
        $OutputPath = '.\'
        $LogFileName = $(get-date -Format yyyy-MM-dd_HH-mm-ss)
        $Log = Join-Path $OutputPath ($LogFileName + "-Groups.csv")

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
        if ($filterElements) {
            $filterString = '({0})' -f ($filterElements -join (') -{0} (' -f $JoinType))
            $filter = [ScriptBlock]::Create($filterString)
            Write-Verbose "Filter being used: $filter"
        }
    }
    Process {
        ForEach ($CurRow in $Row) {
            # Add Error Handling for more than one SMTP:
            $Display = $CurRow.Name
            $GroupType = $CurRow.GroupType
            $EmailAddresses = $CurRow.EmailAddresses
            $PrimarySmtpAddress = $CurRow.PrimarySmtpAddress
            $objectGUID = $CurRow.objectGUID
            $OU = $CurRow.OU
            if ($filter) {    
                $Member = $CurRow."$FindAddressInColumn" -split ";" | Where-Object $filter
            }
            else {
                $Member = $CurRow.EmailAddresses -split ";"
            }
            if ($Domain) {
                $Member = $Member | ForEach-Object {
                    $_ -replace ([Regex]::Escape($Domain), $NewDomain)
                }
            }
            $PrimarySMTP = $CurRow.EmailAddresses -split ";" | Where-Object {$_ -cmatch 'SMTP:'}

            if ($Member) {
                foreach ($CurMember in $Member) {
                    [PSCustomObject]@{
                        Name               = $Display
                        OU                 = $OU
                        objectGUID         = $objectGUID
                        PrimarySmtpAddress = $PrimarySmtpAddress
                        GroupType          = $GroupType
                        Member             = $CurMember
                        EmailAddresses     = $EmailAddresses
                    } | Export-Csv $Log -Append -NoTypeInformation -Encoding UTF8
                } 
            }
            else {
                [PSCustomObject]@{
                    Name               = $Display
                    OU                 = $OU
                    objectGUID         = $objectGUID
                    PrimarySmtpAddress = $PrimarySmtpAddress
                    GroupType          = $GroupType
                    Member             = "NONE"
                    EmailAddresses     = $EmailAddresses
                } | Export-Csv $Log -Append -NoTypeInformation -Encoding UTF8
            }
        }
    }
    End {

    }
}
