function Switch-AddressDomain { 
    <#

.SYNOPSIS
Modifies PrimarySMTPAddress via Active Directory by changing domain from old to new.  Makes the primary address a secondary (additional) smtp address.
Optionally, changes the UPN, changes the mail attributes or clears all proxy addresses first.

.DESCRIPTION
Modifies PrimarySMTPAddress via Active Directory by changing domain from old to new.  Makes the primary address a secondary (additional) smtp address.
Optionally, changes the UPN, changes the mail attributes or clears all proxy addresses first.

.PARAMETER Row
Input of a CSV that includes a minimum of Distinguished Names

.PARAMETER OldDomain
The domain from which are going to change the primary SMTP suffix

.PARAMETER NewDomain
The domain to which are going to change the primary SMTP suffix

.PARAMETER SwitchUPNDomain
UserPrincipalName becomes the Primary SMTP address

.PARAMETER SwitchMailDomain
Mail attribute becomes the Primary SMTP address

.PARAMETER FirstClearAllProxyAddresses
This should be used with extreme caution and is self explanatory.

.PARAMETER LogOnly
Run this first.  Outputs log file of "what-if"

.EXAMPLE
Import-Csv .\CsvOfDNs.csv | Switch-AddressDomain -OldDomain "contoso.com" -NewDomain "fabrikam.com" -SwitchUPNDomain -SwitchMailDomain -LogOnly -Verbose

.EXAMPLE
Import-Csv .\CsvOfDNs.csv | Switch-AddressDomain -OldDomain "contoso.com" -NewDomain "fabrikam.com" -SwitchUPNDomain -SwitchMailDomain -Verbose

.NOTES
Input of Distinguished Names are expected in CSV with DistinguishedName header in your CSV

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
            Write-Warning "Must use NewDomain parameter when specifying OldDomain parameter"
            break
        }
        if ($NewDomain -and (-not $OldDomain)) {
            Write-Warning "Must use OldDomain parameter when specifying NewDomain parameter"
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

            $NewAlternateFromOldPrimary = "smtp:{0}" -f $OldPrimarySMTPTrimmed

            $Address = @(
                $NewPrimarySMTP
                $NewAlternateFromOldPrimary
            )

            if ($NewSIP) {
                $Address += $NewSIP
                # $Address.Add($NewSIP)
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
