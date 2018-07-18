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
    
    .PARAMETER UpdateMailAttribute
    Parameter description
    

    
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
        [Switch]$UpdateMailAttribute,

        [Parameter()]
        [string]$Domain,

        [Parameter()]
        [string]$NewDomain,

        [Parameter()]
        [string]$ChangeDomainOnPrimarySmtpUpnMail,

        [Parameter()]
        [Switch]$LogOnly

    )
    Begin {
        if ($Domain -and (-not $NewDomain)) {
            Write-Warning "Must use NewDomain parameter when specifying Domain parameter"
            break
        }
        if ($NewDomain -and (-not $Domain)) {
            Write-Warning "Must use Domain parameter when specifying NewDomain parameter"
            break
        }
        if ($ChangeDomainOnPrimarySmtpUpnMail -and (-not $Domain)) {
            Write-Warning "Must use Domain and NewDomain parameters when specifying ChangeDomainOnPrimarySmtpUpnMail parameter"
            break
        }
        Import-Module ActiveDirectory -Verbose:$False
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
            $Display = $CurRow.Displayname
            [System.Collections.Generic.List[String]]$Address = $CurRow.EmailAddresses -split ";" | Where-Object $filter
            if ($Domain -and (-not $ChangeDomainOnPrimarySmtpUpnMail)) {
                $Address = $Address | ForEach-Object {
                    $_ -replace ([Regex]::Escape($Domain), $NewDomain)
                }
            }
            $PrimarySMTP = $CurRow.EmailAddresses -split ";" | Where-Object {$_ -cmatch 'SMTP:'}

            if ($PrimarySMTP) {
                $UPNandMail = ($PrimarySMTP.Substring(5)).ToLower()
            }
            if ($ChangeDomainOnPrimarySmtpUpnMail) {
                $ChangePrimaryToSecondary = "smtp:{0}" -f $UPNandMail
                $Address = $PrimarySMTP | ForEach-Object {
                    $_ -replace ([Regex]::Escape($Domain), $NewDomain)
                }
                $Address.AddRange($ChangePrimaryToSecondary)
                $UPNandMail = $UPNandMail | ForEach-Object {
                    $_ -replace ([Regex]::Escape($Domain), $NewDomain)
                }
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
    
                    if ($UpdateMailAttribute) {
                        $params.EmailAddress = $UPNandMail
                    }

                    if ($params.Count -gt 0) {
                        $user | Set-ADUser @params
                        If ($UpdateUPN) {
                            Write-Verbose "$Display `t Set UserPrincipalName $UPNandMail"
                        }
                        if ($UpdateMailAttribute) {
                            Write-Verbose "$Display `t Set Mail Attribute $UPNandMail"
                        }
                    }
                    if ($ChangeDomainOnPrimarySmtpUpnMail) {
                        Set-ADUser -Identity $ObjectGUID -remove @{ProxyAddresses = $PrimarySMTP}
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
