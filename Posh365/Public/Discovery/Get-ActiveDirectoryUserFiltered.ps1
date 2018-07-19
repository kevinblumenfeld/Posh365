function Get-ActiveDirectoryUserFiltered { 
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Row
    Parameter description

    .PARAMETER JoinType
    Parameter description

    .PARAMETER EqualsAnd
    Parameter description

    .PARAMETER EqualsOr
    Parameter description

    .PARAMETER LogOnly
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param (

        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $Row,

        [Parameter(Mandatory = $true)]
        [ValidateSet("and", "or")]
        [String]$JoinType,

        [Parameter()]
        [String[]]$EqualsAnd,

        [Parameter()]
        [String[]]$EqualsOr,

        [Parameter()]
        [Switch]$LogOnly

    )
    Begin {
        Import-Module ActiveDirectory -Verbose:$False
        $OutputPath = 'C:\Scripts'
        $InputPath = 'C:\Scripts'
        $LogFileName = $(get-date -Format yyyy-MM-dd_HH-mm-ss)
        $Log = Join-Path $OutputPath ($LogFileName + "-WhatIf_Import.csv")
        $ErrorLog = Join-Path $OutputPath ($LogFileName + "-Error_Log.csv")
        $ListOUs = Join-Path $InputPath (OUs.csv)
        $ListDepts = Join-Path $InputPath (Depts.csv)
        $ListCities = Join-Path $InputPath (Cities.csv)

        $OUs = Get-Content $ListOUs
        $Depts = Get-Content $ListDepts
        $Cities = Get-Content $ListCities

        $filterElements = $psboundparameters.Keys | Where-Object { $_ -match 'Equals' } | ForEach-Object {

            if ($_.EndsWith('And')) {
                $logicOperator = ' -and '
            }
            else {
                $logicOperator = ' -or '
            }
            
            $comparisonOperator = switch ($_) {
                { $_.StartsWith('Equals') } { '-eq' }
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
            $Display = $CurRow.Displayname
            $Address = $CurRow.EmailAddresses -split ";" | Where-Object $filter
            if ($Domain) {
                $Address = $Address | ForEach-Object {
                    $_ -replace ([Regex]::Escape($Domain), $NewDomain)
                }
            }
            $PrimarySMTP = $CurRow.EmailAddresses -split ";" | Where-Object {$_ -cmatch 'SMTP:'}
            
            if ($PrimarySMTP) {
                $UPNandMail = ($PrimarySMTP.Substring(5)).ToLower()
            }
            if (-not $LogOnly) {
                try {
                    $errorActionPreference = 'Stop'
                    $user = Get-ADUser -Filter { displayName -eq $Display } -Properties proxyAddresses, mail, objectGUID
                    $ObjectGUID = $user.objectGUID

                    if ($FirstClearAllProxyAddresses) {
                        $user | Set-ADUser -clear ProxyAddresses
                        Write-Verbose "$Display `t Cleared ProxyAddresses"
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
                        If ($UpdateUPN) {
                            Write-Verbose "$Display `t Set UserPrincipalName $UPNandMail"
                        }
                        if ($UpdateEmailAddress) {
                            Write-Verbose "$Display `t Set EmailAddress $UPNandMail"
                        }
                    }

                    $Address | ForEach-Object {
                        Set-ADUser -Identity $ObjectGUID -Add @{ProxyAddresses = "$_"}
                        Write-Verbose "$Display `t Set ProxyAddress $($_)"
                    }
                }
                catch {
                    [PSCustomObject]@{
                        DisplayName = $Display
                        Error       = $_
                        UPNandMail  = $UPNandMail
                        Addresses   = $Address -join ','
                        
                    } | Export-Csv $ErrorLog -Append -NoTypeInformation -Encoding UTF8
                }
            }
            else {
                if ($Address) {
                    [PSCustomObject]@{
                        DisplayName = $Display
                        UPNandMail  = $UPNandMail
                        Addresses   = $Address -join ','
                    } | Export-Csv $Log -Append -NoTypeInformation -Encoding UTF8
                }
            }
        }
    }
    End {

    }
}