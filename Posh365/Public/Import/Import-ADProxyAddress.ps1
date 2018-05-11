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
    
    .PARAMETER MatchNot
    Parameter description
    
    .PARAMETER caseMatchNot
    Parameter description
    
    .PARAMETER MatchNotAnd
    Parameter description
    
    .PARAMETER caseMatchNotAnd
    Parameter description
    
    .PARAMETER FirstClearAllProxyAddresses
    Parameter description
    
    .PARAMETER UpdateUPN
    Parameter description
    
    .PARAMETER UpdateEmailAddress
    Parameter description
    
    .EXAMPLE
    Import-Csv .\CSVofADUsers.csv | Import-ADProxyAddress -caseMatchAnd "brann" -MatchNotAnd @("JAIME","John") -JoinType and

    .EXAMPLE
    Import-Csv .\CSVofADUsers.csv | Import-ADProxyAddress -caseMatchAnd "Harry Franklin" -MatchNotAnd @("JAIME","John") -JoinType or

    .NOTES
    Input of ProxyAddresses are exptected to be semicolon seperated
    
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
        [Switch]$FirstClearAllProxyAddresses,
        
        [Parameter()]
        [Switch]$UpdateUPN,

        [Parameter()]
        [Switch]$UpdateEmailAddress

    )
    Begin {
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
        ForEach ($CurRow in $Row) {
            # Add Error Handling for more than one SMTP:
            $Address = $CurRow.EmailAddresses -split ";" | Where-Object $filter

            $PrimarySMTP = $CurRow.EmailAddresses -split ";" | Where-Object {$_ -cmatch 'SMTP:'}
                    
            $UPNandMail = $PrimarySMTP.Substring(5)
            if ($pscmdlet.ShouldProcess('Setting AD User Attributes')) {
                try {
                    $errorActionPreference = 'Stop'
                    $DisplayName = $_.CurRow.Displayname
                    $user = Get-ADUser -Filter { displayName -eq $displayName } -Properties proxyAddresses, mail

                    if ($FirstClearAllProxyAddresses) {
                        $user | Set-ADUser -clear ProxyAddresses
                    }

                    $params = @{}
                    if ($UpdateUPN) {
                        $params.UserPrincipalName = $UPNandMail
                    }
    
                    if ($UpdateEmailAddress) {
                        $params.EmailAddress = $UPNandMail
                    }

                    if ($params.Count -gt 0) {
                        $user | Set-ADUser @params
                    }

                    $Address | ForEach-Object {
                        Get-ADUser -Filter {DisplayName -eq $DisplayName} -Properties ProxyAddresses |
                            Set-ADUser -Add @{ProxyAddresses = "$_"}
                    }
                }
                catch {
                    [PSCustomObject]@{
                        DisplayName = $DisplayName
                        Error       = $_
                        UPNandMail  = $UPNandMail
                        Addresses   = $Address -join ','
                        
                    } | Export-Csv $ErrorLog -Append
                }
            }
            else {
                if ($Address) {
                    [PSCustomObject]@{
                        DisplayName = $DisplayName
                        UPNandMail  = $UPNandMail
                        Addresses   = $Address -join ','
                    } | Export-Csv $Log -Append
                }
            }
        }
    }
    End {

    }
}