function Switch-AddressDomain { 
    <#
    .SYNOPSIS
    Modifies PrimarySMTPAddress via Active Directory by changing domain from old to new.  Makes the primary address a secondary smtp address.
    Optionally, changes the UPN and mail attributes.

    .DESCRIPTION
    Modifies PrimarySMTPAddress via Active Directory by changing domain from old to new.  Makes the primary address a secondary smtp address.
    Optionally, changes the UPN and mail attributes.
    
    .PARAMETER Row
    Parameter description
    
    .PARAMETER FirstClearAllProxyAddresses
    Parameter description
    
    .PARAMETER SwitchUPNDomain
    Parameter description
    
    .PARAMETER SwitchMailDomain
    Parameter description
    
    .PARAMETER OldDomain
    Parameter description
    
    .PARAMETER NewDomain
    Parameter description
    
    .PARAMETER LogOnly
    Parameter description
    
    .EXAMPLE
    Import-Csv .\CSVofADUsers.csv | Import-ADProxyAddress -Domain "contoso.com" -NewDomain "fabrikam.com" -UpdateUPN -UpdateMailAttribute -JoinType and

    .NOTES
    Input of ProxyAddresses are expected to be semicolon separated and header should be "EmailAddresses"

    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (

        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $Row,

        [Parameter()]
        [string]$OldDomain,

        [Parameter()]
        [string]$NewDomain,
        
        [Parameter()]
        [Switch]$SwitchUPNDomain,

        [Parameter()]
        [Switch]$SwitchMailDomain,
        
        [Parameter()]
        [Switch]$FirstClearAllProxyAddresses,

        [Parameter()]
        [Switch]$LogOnly

    )
    Begin {
        if ($OldDomain -and (-not $NewDomain)) {
            Write-Warning "Must use NewDomain parameter when specifying Domain parameter"
            break
        }
        if ($NewDomain -and (-not $OldDomain)) {
            Write-Warning "Must use Domain parameter when specifying NewDomain parameter"
            break
        }

        Import-Module ActiveDirectory -Verbose:$False
        $OutputPath = '.\'
        $LogFileName = $(get-date -Format yyyy-MM-dd_HH-mm-ss)
        $Log = Join-Path $OutputPath ($LogFileName + "-WhatIf_Import.csv")
        $ErrorLog = Join-Path $OutputPath ($LogFileName + "-Error_Log.csv")
    }
    Process {
        ForEach ($CurRow in $Row) {
            $Address = New-Object System.Collections.Generic.List[String]
            $DistinguishedName = $CurRow.DistinguishedName
            $ADUser = Get-ADUser -Filter {DistinguishedName -eq $DistinguishedName} -Properties proxyAddresses, mail, ObjectGUID, DisplayName
            $DisplayName = $ADuser.DisplayName
            $Mail = $ADuser.Mail
            $ObjectGUID = $ADUser.ObjectGUID
            $UserPrincipalName = $ADUser.UserPrincipalName

            $OldPrimarySMTP = $ADUser.ProxyAddresses | Where-Object {$_ -cmatch 'SMTP:'}
            $NewPrimarySMTP = $OldPrimarySMTP | ForEach-Object {
                $_ -replace ([Regex]::Escape($OldDomain), $NewDomain)
            }

            $OldSIP = $ADUser.ProxyAddresses | Where-Object {$_ -cmatch 'SIP:'}
            $NewSIP = $OldSIP | ForEach-Object {
                $_ -replace ([Regex]::Escape($OldDomain), $NewDomain)
            }

            $OldPrimarySMTPTrimmed = $($OldPrimarySMTP.Substring(5)).ToLower()
            $NewUPNandMail = $OldPrimarySMTPTrimmed | ForEach-Object {
                $_ -replace ([Regex]::Escape($OldDomain), $NewDomain)
            }

            $NewAlternateFromOldPrimary = "smtp:{0}" -f $NewUPNandMail

            $Address.Add($NewPrimarySMTP)
            $Address.Add($NewAlternateFromOldPrimary)
            if ($NewSIP) {
                $Address.Add($NewSIP)
            }

            if (-not $LogOnly) {
                try {
                    $errorActionPreference = 'Stop'

                    if ($FirstClearAllProxyAddresses) {
                        $ADUser | Set-ADUser -clear ProxyAddresses
                        Write-Verbose "$DisplayName `t Cleared ProxyAddresses"
                    }

                    $params = @{}
                    if ($SwitchUPNDomain) {
                        $params.UserPrincipalName = $NewUPNandMail
                        Write-Verbose "$DisplayName `t Setting UserPrincipalName $NewUPNandMail"
                    }
    
                    if ($SwitchMailDomain) {
                        $params.EmailAddress = $NewUPNandMail
                        Write-Verbose "$DisplayName `t Setting Mail Attribute $NewUPNandMail"
                    }

                    if ($params.Count -gt 0) {
                        $ADUser | Set-ADUser @params
                    }

                    Set-ADUser -Identity $ObjectGUID -remove @{ProxyAddresses = $OldPrimarySMTP}

                    $Address | ForEach-Object {
                        Set-ADUser -Identity $ObjectGUID -Add @{ProxyAddresses = "$_"}
                        Write-Verbose "$DisplayName `t Set ProxyAddress $($_)"
                    }
                }
                catch {
                    [PSCustomObject]@{
                        DisplayName       = $DisplayName
                        ObjectGUID        = $ObjectGUID
                        Error             = $_
                        OldMail           = $Mail
                        OldUPN            = $UserPrincipalName
                        NewUPNandMail     = $NewUPNandMail
                        NewPrimarySMTP    = $NewPrimarySMTP
                        NewSIP            = $NewSIP
                        NewAlternate      = $NewAlternateFromOldPrimary
                        Addresses         = $Address -join ';'
                        DistinguishedName = $DistinguishedName
                    } | Export-Csv $ErrorLog -Append -NoTypeInformation -Encoding UTF8
                }
            }
            else {
                if ($Address) {
                    [PSCustomObject]@{
                        DisplayName       = $DisplayName
                        ObjectGUID        = $ObjectGUID
                        OldMail           = $Mail
                        OldUPN            = $UserPrincipalName
                        NewUPNandMail     = $NewUPNandMail
                        NewPrimarySMTP    = $NewPrimarySMTP
                        NewSIP            = $NewSIP
                        NewAlternate      = $NewAlternateFromOldPrimary
                        Addresses         = $Address -join ';'
                        DistinguishedName = $DistinguishedName
                    } | Export-Csv $Log -Append -NoTypeInformation -Encoding UTF8
                }
            }
        }
    }
    End {

    }
}
