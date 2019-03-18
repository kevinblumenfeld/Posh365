function Import-QADAlias {
    <#
    .SYNOPSIS
    Imports Non-Primary ProxyAddresses (aliases) into an ADUser's ProxyAddresses attribute.

    .DESCRIPTION
    Finds AD user by searching ProxyAddresses of all AD Users in a domain - by using the PrimarySmtpAddress column of CSV
    Imports Non-Primary ProxyAddresses (aliases) into an ADUser.

    .PARAMETER OutputPath
    Specify a path without a file name. (for example c:\scripts)

    .PARAMETER LogOnly
    Use this to generate simulation of changes to be made and output to a log file.

    .PARAMETER Row
    Used by the pipeline typically. Can be ignored if following examples

    .EXAMPLE
    Import-Csv c:\scripts\sourcedata.csv | Import-QADAlias -OutputPath "c:\scripts" -LogOnly
    This example will make no changes and only log the proposed changes

    .EXAMPLE
    Import-Csv c:\scripts\sourcedata.csv | Import-QADAlias -OutputPath "c:\scripts"
    This example will make changes to each AD User found in Active Directory that matches a ProxyAddress to the column PrimarySmtpAddress in the csv

    .NOTES
    Format of CSV has minimum 2 columns with the headers seen in the example below.

    Example of CSV with mandatory headers:

    PrimarySmtpAddress, Alias
    joe@contoso.com, smtp:joe.smith@contoso.com

    #>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param (

        [Parameter(Mandatory = $true)]
        [String] $OutputPath,

        [Parameter()]
        [Switch]$LogOnly,

        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $Row

    )
    begin {

        $LogFileName = $(Get-Date -Format yyyy-MM-dd_HH-mm-ss)
        $WhatIfLog = Join-Path $OutputPath ($LogFileName + "-QAD-WHAT-IF.csv")
        $Log = Join-Path $OutputPath ($LogFileName + "-QAD-Log.csv")
        Start-Transcript -Path (Join-Path $OutputPath ($LogFileName + "-PowerShell_Transcript_Import.csv"))

    }
    process {

        foreach ($CurRow in $Row) {

            $PrimarySmtpAddress = "SMTP:$($CurRow.PrimarySmtpAddress)"
            $Alias = $CurRow.Alias

            Write-Host "$PrimarySmtpAddress"

            if ($LogOnly) {

                [PSCustomObject]@{
                    Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                    Result             = 'LOGONLY'
                    Action             = 'ADD'
                    Object             = 'ADATTRIBUTE'
                    PrimarySmtpAddress = $PrimarySmtpAddress
                    Alias              = $Alias

                } | Export-Csv -Path $WhatIfLog -NoTypeInformation -Append -Encoding UTF8

            }
            else {
                try {
                    $User = Get-ADUser -Filter "ProxyAddresses -eq '$PrimarySmtpAddress'" -Properties DisplayName, ProxyAddresses, Mail
                    if ($User) {
                        if ($User.count -gt 1) {

                            Write-Host "Failed: $PrimarySmtpAddress more than one AD User has ProxyAddresses attribute with the value" -ForegroundColor Red
                            Write-Host "Failed: $PrimarySmtpAddress please remove from one of the following AD Users:" -ForegroundColor Red
                            foreach ($U in $User) {
                                Write-Host "Failed: $($U.DisplayName) duplicate proxy address" -ForegroundColor Red

                                [PSCustomObject]@{
                                    Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                                    Result             = 'FAILED'
                                    Action             = 'DUPLICATEPROXY'
                                    Object             = $U.DisplayName
                                    PrimarySmtpAddress = $PrimarySmtpAddress
                                    Alias              = $Alias
                                    Mail               = $U.Mail
                                    ProxyBackup        = [string]::join('|', [string[]]$U.ProxyAddresses)
                                    FullNameError      = $U.DistinguishedName
                                    Message            = $U.DistinguishedName -replace '^.+?,(?=(OU|CN)=)'
                                    ExtendedMessage    = $U.ObjectGUID

                                } | Export-Csv -Path $Log -NoTypeInformation -Append -Encoding UTF8
                            }
                        }
                        else {
                            Write-Host "Success: $($User.DisplayName) found with proxy address: $PrimarySmtpAddress" -ForegroundColor Green

                            [PSCustomObject]@{
                                Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                                Result             = 'SUCCESS'
                                Action             = 'GETADUSER'
                                Object             = $User.DisplayName
                                PrimarySmtpAddress = $PrimarySmtpAddress
                                Alias              = $Alias
                                Mail               = $User.Mail
                                ProxyBackup        = [string]::join('|', [string[]]$User.ProxyAddresses)
                                FullNameError      = $User.DistinguishedName
                                Message            = $User.DistinguishedName -replace '^.+?,(?=(OU|CN)=)'
                                ExtendedMessage    = $User.ObjectGUID

                            } | Export-Csv -Path $Log -NoTypeInformation -Append -Encoding UTF8

                            $User | Set-ADUser -ErrorAction Stop -Add @{
                                ProxyAddresses = $Alias
                            }
                            Write-Host "Success: $($User.DisplayName) added proxy address $Alias" -ForegroundColor Green

                            [PSCustomObject]@{
                                Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                                Result             = 'SUCCESS'
                                Action             = 'ADDPROXY'
                                Object             = $User.DisplayName
                                PrimarySmtpAddress = $PrimarySmtpAddress
                                Alias              = $Alias
                                Mail               = $User.Mail
                                ProxyBackup        = [string]::join('|', [string[]]$User.ProxyAddresses)
                                FullNameError      = $User.DistinguishedName
                                Message            = $User.DistinguishedName -replace '^.+?,(?=(OU|CN)=)'
                                ExtendedMessage    = $User.ObjectGUID

                            } | Export-Csv -Path $Log -NoTypeInformation -Append -Encoding UTF8

                            $NewData = $User | Get-ADUser -Properties DisplayName, ProxyAddresses, Mail

                            [PSCustomObject]@{
                                Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                                Result             = 'RESULT'
                                Action             = 'ADDPROXY'
                                Object             = $NewData.DisplayName
                                PrimarySmtpAddress = $PrimarySmtpAddress
                                Alias              = $Alias
                                Mail               = $NewData.Mail
                                ProxyBackup        = [string]::join('|', [string[]]$NewData.ProxyAddresses)
                                FullNameError      = $User.DistinguishedName
                                Message            = $User.DistinguishedName -replace '^.+?,(?=(OU|CN)=)'
                                ExtendedMessage    = $User.ObjectGUID

                            } | Export-Csv -Path $Log -NoTypeInformation -Append -Encoding UTF8
                        }
                    }
                    else {
                        Write-Host "Failed: $PrimarySmtpAddress not found" -ForegroundColor Red

                        [PSCustomObject]@{
                            Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                            Result             = 'USERNOTFOUND'
                            Action             = 'GETADUSER'
                            Object             = 'ADUSER'
                            PrimarySmtpAddress = $PrimarySmtpAddress
                            Alias              = $Alias
                            Mail               = 'USERNOTFOUND'
                            ProxyBackup        = 'USERNOTFOUND'
                            FullNameError      = 'USERNOTFOUND'
                            Message            = 'USERNOTFOUND'
                            ExtendedMessage    = 'USERNOTFOUND'

                        } | Export-Csv -Path $Log -NoTypeInformation -Append -Encoding UTF8
                    }
                }
                catch {
                    Write-Host "Failed: $($User.DisplayName) not added proxy address $Alias" -ForegroundColor Red

                    [PSCustomObject]@{
                        Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                        Result             = 'PROXYNOTADDED'
                        Action             = 'SETADUSER'
                        Object             = $User.DisplayName
                        PrimarySmtpAddress = $PrimarySmtpAddress
                        Alias              = $Alias
                        Mail               = $User.Mail
                        ProxyBackup        = [string]::join('|', [string[]]$User.ProxyAddresses)
                        FullNameError      = $_.Exception.GetType().fullname
                        Message            = $_.CategoryInfo.Reason
                        ExtendedMessage    = $_.Exception.Message

                    } | Export-Csv -Path $Log -NoTypeInformation -Append -Encoding UTF8
                }
            }
        }
    }
    end {

    }
}
