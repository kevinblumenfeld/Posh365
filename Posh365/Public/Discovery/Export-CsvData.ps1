function Export-CsvData { 
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
Parameter description

.PARAMETER caseMatch
Parameter description

.PARAMETER matchAnd
Parameter description

.PARAMETER caseMatchAnd
Parameter description

.PARAMETER MatchNot
Parameter description

.PARAMETER caseMatchNot
Parameter description

.PARAMETER MatchNotAnd
Parameter description

.PARAMETER caseMatchNotAnd
Parameter description

.PARAMETER Domain
Parameter description

.PARAMETER NewDomain
Parameter description

.EXAMPLE
Import-Csv .\CSVofADUsers.csv | Export-CsvData -caseMatchAnd "brann" -MatchNotAnd @("JAIME","John") -JoinType and

.EXAMPLE
Import-Csv .\CSVofADUsers.csv | Export-CsvData -caseMatchAnd "Harry Franklin" -MatchNotAnd @("JAIME","John") -JoinType or

.NOTES
Input of ProxyAddresses are expected to be semicolon separated.

#>
    [CmdletBinding(SupportsShouldProcess)]
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
        $Log = Join-Path $OutputPath ($LogFileName + "-EmailAddresses.csv")

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
            $Display = $CurRow.Displayname
            $RecipientTypeDetails = $CurRow.RecipientTypeDetails
            $PrimarySmtpAddress = $CurRow.PrimarySmtpAddress
            if ($filter) {
                $Address = $CurRow.EmailAddresses -split ";" | Where-Object $filter
            }
            else {
                $Address = $CurRow.EmailAddresses -split ";"
            }
            if ($Domain) {
                $Address = $Address | ForEach-Object {
                    $_ -replace ([Regex]::Escape($Domain), $NewDomain)
                }
            }
            $PrimarySMTP = $CurRow.EmailAddresses -split ";" | Where-Object {$_ -cmatch 'SMTP:'}

            if ($Address) {
                foreach ($CurAddress in $Address) {
                    [PSCustomObject]@{
                        DisplayName          = $Display
                        PrimarySmtpAddress   = $PrimarySmtpAddress
                        RecipientTypeDetails = $RecipientTypeDetails
                        EmailAddress         = $CurAddress
                    } | Export-Csv $Log -Append -NoTypeInformation -Encoding UTF8
                } 
            }
            else {
                [PSCustomObject]@{
                    DisplayName          = $Display
                    PrimarySmtpAddress   = $PrimarySmtpAddress
                    RecipientTypeDetails = $RecipientTypeDetails
                    EmailAddress         = "NONE"
                } | Export-Csv $Log -Append -NoTypeInformation -Encoding UTF8
            }
        }
    }
    End {

    }
}
