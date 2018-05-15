function New-ActiveDirectoryUser { 
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

    .PARAMETER UpdateUPN
    Parameter description
    
    .PARAMETER UpdateEmailAddress
    Parameter description
    
    .EXAMPLE
    Import-Csv .\CSVofADUsers.csv | New-ActiveDirectoryUser -caseMatchAnd "brann" -MatchNotAnd @("JAIME","John") -JoinType and

    .EXAMPLE
    Import-Csv .\CSVofADUsers.csv | New-ActiveDirectoryUser -caseMatchAnd "Harry Franklin" -MatchNotAnd @("JAIME","John") -JoinType or

    .NOTES
    Input of ProxyAddresses are expected to be semicolon seperated.  Password is set to Random Password
    
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (

        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $Row,

        [Parameter(Mandatory = $true)]
        [String]$OU,

        [Parameter()]
        [Switch]$LogOnly

    )
    Begin {

        Import-Module ActiveDirectory -Verbose:$False
        $OutputPath = '.\'
        $LogFileName = $(get-date -Format yyyy-MM-dd_HH-mm-ss)
        $Log = Join-Path $OutputPath ($LogFileName + "-WhatIf_Import.csv")
        $ErrorLog = Join-Path $OutputPath ($LogFileName + "-Error_Log.csv")

    }
    Process {
        ForEach ($CurRow in $Row) {
            # Add Error Handling for more than one SMTP:
            $Display = $CurRow.Displayname
            $Name = $Display.Substring(0, 15)
            $PrimarySMTP = $CurRow.EmailAddresses -split ";" | Where-Object {$_ -cmatch 'SMTP:'}
            
            if ($PrimarySMTP) {
                $UPNandMail = $PrimarySMTP.Substring(5)   
            }
            if (! $LogOnly) {
                try {
                    $errorActionPreference = 'Stop'
                    $NewADUser = @{
                        Path                  = $OU 
                        Name                  = $Name 
                        DisplayName           = $Display
                        UserPrincipalName     = $UPNandMail 
                        Enabled               = $False
                        PasswordNotRequired   = $true
                        ChangePasswordAtLogon = $false
                    }
                    $HashNulls = $NewADUser.GetEnumerator() | Where-Object {
                        $_.Value -eq $null 
                    }
                    $HashNulls | ForEach-Object {
                        $NewADUser.remove($_.key)
                    }
                    New-ADUser @NewADUser

                }
                catch {
                    [PSCustomObject]@{
                        DisplayName = $Display
                        Error       = $_
                        UPNandMail  = $UPNandMail
                        PrimarySMTP = $PrimarySMTP
                        
                    } | Export-Csv $ErrorLog -Append -NoTypeInformation -Encoding UTF8
                }
            }
            else {
                [PSCustomObject]@{
                    DisplayName = $Display
                    Path        = $OU
                    UPNandMail  = $UPNandMail
                    PrimarySMTP = $PrimarySMTP
                } | Export-Csv $Log -Append -NoTypeInformation -Encoding UTF8
            }
        }
    }
    End {

    }
}
