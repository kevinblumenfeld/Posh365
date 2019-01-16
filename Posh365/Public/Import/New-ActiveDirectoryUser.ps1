function New-ActiveDirectoryUser {
    <#
    .SYNOPSIS
    Create New Active Directory Users

    .DESCRIPTION
    Create New Active Directory Users - Mainly for Shared and Resource Mailbox as object is disabled with random password

    .PARAMETER Row
    Parameter description

    .PARAMETER OU
    Parameter description

    .PARAMETER LogOnly
    Parameter description

    .EXAMPLE
    Import-Csv .\Shared_and_Resource_Mailboxes.csv | | New-ActiveDirectoryUser -OU "OU=Shared,OU=CORP,DC=contoso,DC=com"

    .NOTES
    Input of ProxyAddresses are expected to be semicolon seperated.  Password is set to Random Password

    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
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
            $Display = $CurRow.Displayname
            $Name = -join ([char[]]$display | select -first 15)
            $i = 2
            Write-Verbose "Display Name: $Display"
            while (Get-ADUser -filter {samaccountname -eq $name}) {
                $charsForIteration = ([string]$i).Length
                $name = -join ([char[]]$display | select -first (15 - $charsForIteration)) + $i
                $i++
            }
            Write-Verbose "Name: $Name"
            $PrimarySMTP = $CurRow.EmailAddresses -split [regex]::Escape('|') | Where-Object {$_ -cmatch 'SMTP:'}

            if ($PrimarySMTP) {
                $UPNandMail = ($PrimarySMTP.Substring(5)).ToLower()
                Write-Verbose "UPNandMail: $UPNandMail"
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
                        PasswordNeverExpires  = $True
                    }
                    $HashNulls = $NewADUser.GetEnumerator() | Where-Object {
                        $_.Value -eq $null
                    }
                    $HashNulls | ForEach-Object {
                        $NewADUser.remove($_.key)
                    }
                    New-ADUser @NewADUser
                    $distinguishedName = $null
                    $distinguishedName = (Get-ADUser -filter {displayName -eq $Display}).distinguishedname
                    if ($distinguishedName) {
                        Rename-ADObject $distinguishedName -NewName $Display
                    }
                }
                catch {
                    [PSCustomObject]@{
                        DisplayName = $Display
                        Name        = $Name
                        Error       = $_
                        UPNandMail  = $UPNandMail
                        PrimarySMTP = $PrimarySMTP

                    } | Export-Csv $ErrorLog -Append -NoTypeInformation -Encoding UTF8
                }
            }
            else {
                [PSCustomObject]@{
                    DisplayName = $Display
                    Name        = $Name
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
