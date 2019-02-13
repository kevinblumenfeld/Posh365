function Import-QADData {
    <#
    .SYNOPSIS
    Imports (typically from a CSV) at minimum: DisplayName, UserPrincipalName and Mail attributes
    It transforms the mail attribute into MailNickName, TargetAddress & ProxyAddresses attributes
    It uses the Replace method for those three attributes, thus clearing the attribute and adding the one we want

    .DESCRIPTION
    Imports (typically from a CSV) at minimum: DisplayName, UserPrincipalName and Mail attributes
    It transforms the mail attribute into MailNickName, TargetAddress & ProxyAddresses attributes
    It uses the Replace method for those three attributes, thus clearing the attribute and adding the one we want
    This is dependant on the ActiveDirectory module

    .PARAMETER OutputPath
    Specify a path without a file name. (for example c:\scripts)

    .PARAMETER LogOnly
    Use this to generate simulation of changes to be made and output to a log file.

    .PARAMETER Row
    Used by the pipeline typically. Don't manually specify

    .EXAMPLE
    Import-Csv c:\scripts\sourcedata.csv | Import-QADData -OutputPath "c:\scripts" -LogOnly
    This example will make no changes and only log the proposed changes

    .EXAMPLE
    Import-Csv c:\scripts\sourcedata.csv | Import-QADData -OutputPath "c:\scripts"
    This example will make changes to each AD User found in Active Directory that matches the column UserPrincipalName in sourcedata.csv

    .NOTES
    General notes
    #>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param (

        [Parameter(Mandatory = $true)]
        [String] $OutputPath,

        [Parameter()]
        [Switch]$LogOnly,

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
        $Row

    )
    begin {

        $LogFileName = $(get-date -Format yyyy-MM-dd_HH-mm-ss)
        $WhatIfLog = Join-Path $OutputPath ($LogFileName + "-QAD-WHAT-IF.csv")
        $ErrorLog = Join-Path $OutputPath ($LogFileName + "-QAD-Error_Log.csv")
        Start-Transcript -Path (Join-Path $OutputPath ($LogFileName + "-PowerShell_Transcript_Import.csv"))

    }
    process {

        foreach ($CurRow in $Row) {

            $DisplayName = $CurRow.DisplayName
            $Upn = $CurRow.UserPrincipalName
            $Mail = $CurRow.Mail

            $MailNickName = ($Mail -split '@')[0]
            $TargetAddress = 'SMTP:{0}' -f $Mail
            $PrimaryProxy = $TargetAddress

            if ($LogOnly) {

                [PSCustomObject]@{
                    Time                  = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                    Result                = 'LOGONLY'
                    Action                = 'REPLACE'
                    Object                = 'ADATTRIBUTES'
                    DisplayName           = $DisplayName
                    UserPrincipalName     = $Upn
                    Mail                  = $Mail
                    ProposedTargetAddress = $TargetAddress
                    ProposedMailNickName  = $MailNickName
                    ProposedProxyAddress  = $PrimaryProxy

                } | Export-Csv -Path $WhatIfLog -NoTypeInformation -Append -Encoding UTF8

            }

            else {
                try {

                    $User = Get-ADUser -Filter "UserPrincipalName -eq '$Upn'"

                    if ($User) {

                        $User | Set-ADUser -ErrorAction Stop -Replace @{
                            TargetAddress  = $TargetAddress
                            MailNickName   = $MailNickName
                            ProxyAddresses = $PrimaryProxy
                        }

                        Write-Host "$DisplayName" -ForegroundColor White
                        Write-Host "Success: TargetAddress:`t$TargetAddress" -ForegroundColor Green
                        Write-Host "Success: MailNickName:`t$MailNickName" -ForegroundColor Green
                        Write-Host "Success: PrimarySMTP:`t$PrimaryProxy" -ForegroundColor Green
                    }
                    else {
                        Write-Host "FAILED TO FIND AD USER:`t$DisplayName" -ForegroundColor Red

                        [PSCustomObject]@{
                            Time                  = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                            Result                = 'USERNOTFOUND'
                            Action                = 'GET'
                            Object                = 'ADUSER'
                            DisplayName           = $DisplayName
                            UserPrincipalName     = $Upn
                            Mail                  = $Mail
                            ProposedTargetAddress = $TargetAddress
                            ProposedMailNickName  = $MailNickName
                            ProposedProxyAddress  = $PrimaryProxy
                            FullNameError         = 'USERNOTFOUND'
                            Message               = 'USERNOTFOUND'
                            ExtendedMessage       = 'USERNOTFOUND'

                        } | Export-Csv -Path $ErrorLog -NoTypeInformation -Append -Encoding UTF8
                    }
                }
                catch {
                    Write-Host "FAILED (CHECK LOGS):`t$DisplayName" -ForegroundColor Red

                    [PSCustomObject]@{
                        Time                  = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                        Result                = 'FAILURE'
                        Action                = 'REPLACE'
                        Object                = 'ADATTRIBUTES'
                        DisplayName           = $DisplayName
                        UserPrincipalName     = $Upn
                        Mail                  = $Mail
                        ProposedTargetAddress = $TargetAddress
                        ProposedMailNickName  = $MailNickName
                        ProposedProxyAddress  = $PrimaryProxy
                        FullNameError         = $_.Exception.GetType().fullname
                        Message               = $_.CategoryInfo.Reason
                        ExtendedMessage       = $_.Exception.Message

                    } | Export-Csv -Path $ErrorLog -NoTypeInformation -Append -Encoding UTF8
                }
            }
        }
    }
    end {

    }
}
