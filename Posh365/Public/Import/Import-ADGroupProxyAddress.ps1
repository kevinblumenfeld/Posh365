function Import-ADGroupProxyAddress { 
    <#
    .SYNOPSIS
    Import ProxyAddresses into Active Directory from a CSV file.

    .DESCRIPTION
    Import ProxyAddresses into Active Directory.  Also, can clear existing proxyaddresses.
    Can update MAIL attribute with the Primary SMTP Address it finds in the column you choose.

    .PARAMETER LogOnly
    Always use this parameter to show a "WHAT IF" scenario prior to using in production.  It creates a file in the directory from which you executed this script.
    
    .PARAMETER FindADGroupBy
    This uses the AD Attributes named either: "Mail", "UserPrincipalName", or "DisplayName".
    When finding the AD Group by "Mail" attribute the script looks in the CSV for the column headers ProxyAddresses, Mail then WindowsEmailAddress.
    The script matches against the first mail attribute with the value it finds in the first column (in the CSV) that has data.
    So if ProxyAddresses column has data, Mail and WindowsEmailAddress columns will not be considered.
    
    .PARAMETER FindAddressInColumn
    In the CSV passed the function will look in one of these columns to find the email addresses to be added, "ProxyAddresses", "EmailAddresses", "x500"
    These are the addresses that get populated into AD's ProxyAddresses column.
    
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
    
    .PARAMETER FirstClearAllProxyAddresses
    Use this with caution as it will completely clear out all the addresses in the ProxyAddresses AD Attribute
    
    .PARAMETER UpdateEmailAddress
    Looks for the primarySMTPAddress (SMTP:) in either proxyaddresses or emailaddresses column (depends on your selection with -FindAddressInColumn parameter)
    and uses that to update the AD Group's MAIL attribute
    
    .PARAMETER Domain
    Use to modify what you are importing into 1 or more of the following attributes
    1. proxyaddresses
    2. Mail
    
    It looks for the domain (or any string for that matter) you specify in this attribute and replaces it with the NewDomain Attribute

    .PARAMETER NewDomain
    Use to modify what you are importing into 1 or more of the following attributes
    1. proxyaddresses
    2. Mail
    
    It looks for the domain (or any string for that matter) you specify in the Domain attribute and replaces it with the domain (or any string) from this parameter, NewDomain.
    
    .PARAMETER Row
    Each Row imported via CSV.  Use the method to pass the rows via pipeline instead of this parameter.
    
    .PARAMETER JoinType
    This joins all the elements for the filter string together. Either AND or OR.

        AND or OR are the options here.  This decides if the filter is 

    (foo -eq 'bar' -or bar -eq 'foo') -AND (foo -eq 'bar' -or bar -eq 'foo')
                                        or
    (foo -eq 'bar' -or bar -eq 'foo') -OR (foo -eq 'bar' -or bar -eq 'foo')

    The DEFAULT is AND
    
    .EXAMPLE
    Import-Csv .\groups-Detailed.csv | Import-ADGroupProxyAddress -FindADGroupBy DisplayName -FindAddressInColumn EmailAddresses -Match "contoso.com"

    .EXAMPLE
    Import-Csv .\groups.csv | Import-ADGroupProxyAddress -FindADGroupBy MAIL -FindAddressInColumn EmailAddresses -caseMatch "SMTP:"
    
    .EXAMPLE
    Import-Csv .\groups.csv | Import-ADGroupProxyAddress -FindADGroupBy DisplayName -FindAddressInColumn ProxyAddresses -caseNotMatch "SMTP:"
    
    .EXAMPLE
    Import-Csv .\groups.csv | Import-ADGroupProxyAddress -FindADGroupBy DisplayName -FindAddressInColumn x500 -Match x500
        
    .EXAMPLE
    Import-Csv .\groups.csv | Import-ADGroupProxyAddress -FindADGroupBy DisplayName -FindAddressInColumn ProxyAddresses -Match @("smtp:","onmicrosoft.com") -UpdateEmailAddress

    .EXAMPLE
    Import-Csv .\users.csv | Import-ADGroupProxyAddress -caseMatchAnd @("smtp:","onmicrosoft.com") -JoinType and

    .EXAMPLE
    Import-Csv .\addys.csv | Import-ADGroupProxyAddress -caseMatch "brann" -MatchNotAnd @("JAIME","John") -JoinType and
    
    .EXAMPLE
    Import-Csv .\csv.csv | Import-ADGroupProxyAddress -caseMatch "Harry Franklin" -MatchNotAnd @("JAIME","John") -JoinType or

    .NOTES
    Input of addresses from CSV are expected to be semicolon separated (addresses can originate in 1 of 3 column headers: ProxyAddresses, EmailAddresses or x500)

    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (

        [Parameter()]
        [Switch]$LogOnly,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Mail", "DisplayName")]
        [String]$FindADGroupBy,

        [Parameter(Mandatory = $true)]
        [ValidateSet("ProxyAddresses", "EmailAddresses", "x500")]
        [String]$FindAddressInColumn,

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
        [Switch]$FirstClearAllProxyAddresses,

        [Parameter()]
        [Switch]$UpdateEmailAddress,

        [Parameter()]
        [string]$Domain,

        [Parameter()]
        [string]$NewDomain,

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
        if ($FindAddressInColumn -eq "x500" -and $UpdateEmailAddress) {
            Write-Warning "Unable to update Mail attribute when looking in column with only x500 addresses."
            Write-Warning "Please remove UpdateEmailAddress when using x500 as the value for FindAddressInColumn"
            break
        }
        Import-Module ActiveDirectory -Verbose:$False
        $OutputPath = '.\'
        $LogFileName = $(get-date -Format yyyy-MM-dd_HH-mm-ss)
        $Log = Join-Path $OutputPath ($LogFileName + "-Group-WhatIf_Import.csv")
        $ErrorLog = Join-Path $OutputPath ($LogFileName + "-Group-Error_Log.csv")

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
            $Display = $CurRow.Displayname
            $Mail = $CurRow.primarySMTPAddress
            if (-not $Mail) {
                $Mail = $CurRow.Mail
            }
            if (-not $Mail) {
                $Mail = $CurRow.WindowsEmailAddress
            }
            
            if ($FindAddressInColumn -ne "x500") {
                $PrimarySMTP = $CurRow."$FindAddressInColumn" -split ";" | Where-Object {$_ -cmatch 'SMTP:'}
                $Address = $CurRow."$FindAddressInColumn" -split ";" | Where-Object $filter
            }
            else {
                $Address = $CurRow.x500 -split ";" | Where-Object $filter
            }
            if ($Domain) {
                $Address = $Address | ForEach-Object {
                    $_ -replace ([Regex]::Escape($Domain), $NewDomain)
                }
            }
            if ($PrimarySMTP) {
                $MailAttribute = ($PrimarySMTP.Substring(5)).ToLower()
            }
            if (! $LogOnly) {
                try {
                    $errorActionPreference = 'Stop'
                    switch ($FindADGroupBy) {
                        DisplayName {
                            $user = Get-ADGroup -Filter { displayName -eq $Display } -Properties proxyAddresses, mail, objectGUID
                        }
                        Mail {
                            $user = Get-ADGroup -Filter { mail -eq $Mail } -Properties proxyAddresses, mail, objectGUID
                        }
                    }
                    
                    $ObjectGUID = $user.objectGUID

                    if ($FirstClearAllProxyAddresses) {
                        $user | Set-ADGroup -clear ProxyAddresses
                        Write-Verbose "$Display `t Cleared ProxyAddresses"
                    }

                    $params = @{}

                    if ($UpdateEmailAddress) {
                        $params.EmailAddress = $MailAttribute
                    }

                    if ($params.Count -gt 0) {
                        $user | Set-ADGroup @params
                        if ($UpdateEmailAddress) {
                            Write-Verbose "$Display `t Set EmailAddress $MailAttribute"
                        }
                    }

                    $Address | ForEach-Object {
                        Set-ADGroup -Identity $ObjectGUID -Add @{ProxyAddresses = "$_"}
                        Write-Verbose "$Display `t Set ProxyAddress $($_)"
                    }
                }
                catch {
                    [PSCustomObject]@{
                        DisplayName   = $Display
                        Error         = $_
                        MailAttribute = $MailAttribute
                        Addresses     = $Address -join ','
                        
                    } | Export-Csv $ErrorLog -Append -NoTypeInformation -Encoding UTF8
                }
            }
            else {
                if ($Address) {
                    [PSCustomObject]@{
                        DisplayName   = $Display
                        MailAttribute = $MailAttribute
                        Addresses     = $Address -join ','
                    } | Export-Csv $Log -Append -NoTypeInformation -Encoding UTF8
                }
            }
        }
    }
    End {

    }
}
