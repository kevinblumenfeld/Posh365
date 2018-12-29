function Export-QCsvData {
    <#
.SYNOPSIS
Use Export-CsvData instead.. this is a one-off function!!!!
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
Import-Csv .\CSVofADUsers.csv | Export-QCsvData -caseMatchAnd "brann" -MatchNotAnd @("JAIME","John") -JoinType and -fileName "NewCsv.csv"

.EXAMPLE
Import-Csv .\CSVofADUsers.csv | Export-QCsvData -caseMatchAnd "Harry Franklin" -MatchNotAnd @("JAIME","John") -JoinType or -fileName "NewCsv.csv"

.EXAMPLE
Import-Csv .\CSVofADUsers.csv | Export-QCsvData -Match "." -JoinType and -fileName "NewCsv.csv"
Above matches all in column you choose "FindInColumn" including blanks

.EXAMPLE
Import-Csv .\CSVofADUsers.csv | Export-QCsvData -Match "^\s" -JoinType and -fileName "NewCsv.csv"
Above matches all in column you choose "FindInColumn" excluding blanks. This match currently does not work!

.NOTES
Input (from the CSV) of the Addresses (to be imported into ProxyAddresses attribute in Active Directory) are expected to be semicolon separated.
Example:
import-csv .\file.csv | Export-QCsvData -JoinType and -FindInColumn ProxyAddresses -caseMatch "SMTP:" -StripPrefix -AddPrefix "smtp:" -fileName "NewCsv.csv"
import-csv .\file.csv | Export-QCsvData -JoinType and -FindInColumn ProxyAddresses -caseMatch "SMTP:" -Domain "fabrikam.com" -NewDomain "contoso.com" -fileName "NewCsv.csv"
import-csv .\file.csv | Export-QCsvData -JoinType and -FindInColumn ProxyAddresses -Match "SIP:" -fileName "NewCsv.csv"
import-csv .\file.csv | Export-QCsvData -JoinType and -FindInColumn ProxyAddresses -Match "SIP:" -Domain "fabrikam.com" -NewDomain "contoso.com" -fileName "NewCsv.csv"
import-csv .\file.csv | Export-QCsvData -JoinType and -FindInColumn ProxyAddresses -caseMatch "SMTP:" -fileName "NewCsv.csv"
import-csv .\file.csv | Export-QCsvData -JoinType and -FindInColumn ProxyAddresses -caseMatch "SMTP:" -Domain "fabrikam.com" -NewDomain "contoso.com" -StripPrefix -fileName "NewCsv.csv"

#>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (

        [Parameter()]
        [string]$ReportPath,

        [Parameter(Mandatory = $true)]
        [string]$fileName,

        [Parameter(Mandatory = $true)]
        [ValidateSet("and", "or")]
        [String]$JoinType,

        [Parameter(Mandatory = $true)]
        [ValidateSet("ProxyAddresses", "EmailAddresses", "EmailAddress", "AddressOrMember", "x500", "UserPrincipalName", "PrimarySmtpAddress", "MembersName", "Member", "Members", "MemberOf", "Aliases", "Owners", "Managers")]
        [String]$FindInColumn,

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
        [string]$NewDomain,

        [Parameter()]
        [switch]$StripPrefix,

        [Parameter()]
        [ValidateSet("SMTP:", "smtp:", "SIP:", "sip:", "x500:")]
        [string]$AddPrefix,

        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $Row

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

        if (-not $ReportPath) {
            $ReportPath = '.\'
            $theReport = $ReportPath | Join-Path -ChildPath $fileName
        }
        New-Item -ItemType Directory -Path $ReportPath -ErrorAction SilentlyContinue
        $theReport = $ReportPath | Join-Path -ChildPath $fileName

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
            $Email = $CurRow.Email
            $Name = $CurRow.Name
            $Description = $CurRow.Description
            $DisplayName = $CurRow.DisplayName
            $WhoCanContactOwner = $CurRow.whoCanContactOwner
            $RecipientTypeDetails = $CurRow.RecipientTypeDetails
            $PrimarySmtpAddress = $CurRow.PrimarySmtpAddress
            $objectGUID = $CurRow.objectGUID
            $OU = $CurRow.OU
            $UserPrincipalName = $CurRow.UserPrincipalName
            $msExchRecipientTypeDetails = $CurRow.msExchRecipientTypeDetails
            $mail = $CurRow.mail
            if ($filter) {
                $Address = $CurRow."$FindInColumn" -split "`r`n" | Where-Object $filter
                Write-Verbose "Filtered Address: $Address"
            }
            else {
                $Address = $CurRow.EmailAddresses
            }
            if ($Domain) {
                $Address = $Address | ForEach-Object {
                    $_ -replace ([Regex]::Escape($Domain), $NewDomain)
                }
            }
            if ($StripPrefix) {
                $Address = $Address | ForEach-Object {
                    (($_).split(':'))[1]
                }
            }
            if ($AddPrefix) {
                $Address = $Address | ForEach-Object {
                    '{0}{1}' -f $AddPrefix, $_
                }
            }
            $AllProxyAddresses = $($CurRow."$FindInColumn")

            if ((-not [String]::IsNullOrWhiteSpace($AllProxyAddresses)) -and ([String]::IsNullOrWhiteSpace($PrimarySmtpAddress))) {
                $PrimarySmtpAddress = $CurRow."$FindInColumn" | Where-Object {$_ -cmatch 'SMTP:'}
            }
            if ($PrimarySmtpAddress -cmatch 'SMTP:') {
                $PrimaryTrimmed = $PrimarySmtpAddress.Substring(5)
            }

            if ($Address) {
                foreach ($CurAddress in $Address) {
                    [PSCustomObject]@{
                        Email                      = $Email
                        Name                       = $Name
                        AddressOrMember            = $CurAddress
                        FoundInColumn              = $FindInColumn
                        WhoCanContactOwner         = $WhoCanContactOwner
                        Description                = $Description
                        DisplayName                = $DisplayName
                        OU                         = $OU
                        UserPrincipalName          = $UserPrincipalName
                        PrimarySmtpAddress         = $PrimarySmtpAddress
                        PrimarySmtpTrimmed         = $PrimaryTrimmed
                        RecipientTypeDetails       = $RecipientTypeDetails
                        msExchRecipientTypeDetails = $msExchRecipientTypeDetails
                        objectGUID                 = $objectGUID
                    } | Export-Csv $theReport -Append -NoTypeInformation -Encoding UTF8
                }
            }
            else {
                [PSCustomObject]@{
                    Email                      = $Email
                    Name                       = $Name
                    AddressOrMember            = ""
                    FoundInColumn              = $FindInColumn
                    WhoCanContactOwner         = $WhoCanContactOwner
                    Description                = $Description
                    DisplayName                = $DisplayName
                    OU                         = $OU
                    UserPrincipalName          = $UserPrincipalName
                    PrimarySmtpAddress         = $PrimarySmtpAddress
                    PrimarySmtpTrimmed         = $PrimaryTrimmed
                    RecipientTypeDetails       = $RecipientTypeDetails
                    msExchRecipientTypeDetails = $msExchRecipientTypeDetails
                    objectGUID                 = $objectGUID
                } | Export-Csv $theReport -Append -NoTypeInformation -Encoding UTF8
            }
        }
    }
    End {

    }
}
