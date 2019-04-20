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

    .PARAMETER DomainSuffix
    The UPN prefix from the input file is used. To create mail, proxyaddresses and targetaddress, this suffix is used

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


        [Parameter(Mandatory)]
        [String] $DomainSuffix,

        [Parameter(Mandatory)]
        [String] $OutputPath,

        [Parameter()]
        [Switch]$LogOnly,

        [Parameter(ValueFromPipeline, Mandatory)]
        $Row

    )
    begin {

        $LogFileName = $(get-date -Format yyyy-MM-dd_HH-mm-ss)
        $WhatIfLog = Join-Path $OutputPath ($LogFileName + "-QAD_WHATIF.csv")
        $Log = Join-Path $OutputPath ($LogFileName + "-QADLog.csv")
        Start-Transcript -Path (Join-Path $OutputPath ($LogFileName + "-PowerShell_Transcript_Import.csv"))

    }
    process {

        foreach ($CurRow in $Row) {

            $DisplayName = $CurRow.DisplayName
            $UPN = $CurRow.UserPrincipalName
            $Mail = $CurRow.Mail
            $ObjectGuid = $CurRow.ObjectGUID

            $NewMail = ($UPN -split '@')[0] + "@$DomainSuffix"
            $MailNickName = ($UPN -split '@')[0]
            $TargetAddress = 'SMTP:{0}' -f $NewMail
            $PrimaryProxy = $TargetAddress

            if ($LogOnly) {

                [PSCustomObject]@{
                    Time                  = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                    Result                = 'LOGONLY'
                    Action                = 'REPLACE'
                    Object                = 'ADATTRIBUTES'
                    DisplayName           = $DisplayName
                    UserPrincipalName     = $UPN
                    Mail                  = $Mail
                    ProposedMail          = $NewMail
                    ProposedTargetAddress = $TargetAddress
                    ProposedMailNickName  = $MailNickName
                    ProposedProxyAddress  = $PrimaryProxy
                    ObjectGuid            = $ObjectGuid

                } | Export-Csv -Path $WhatIfLog -NoTypeInformation -Append -Encoding UTF8

            }

            else {
                try {

                    $User = Get-ADUser -Filter "UserPrincipalName -eq '$UPN'"
                    $Guid = $User.ObjectGUID.Guid
                    if ($Guid) {

                        Set-ADUser -Identity $Guid -ErrorAction Stop -Replace @{
                            Mail           = $NewMail
                            TargetAddress  = $TargetAddress
                            MailNickName   = $MailNickName
                            ProxyAddresses = $PrimaryProxy
                        }

                        Write-Host "$DisplayName" -ForegroundColor White
                        Write-Host "Success: Mail:`t`t$NewMail" -ForegroundColor Green
                        Write-Host "Success: TargetAddress:`t$TargetAddress" -ForegroundColor Green
                        Write-Host "Success: MailNickName:`t$MailNickName" -ForegroundColor Green
                        Write-Host "Success: PrimarySMTP:`t$PrimaryProxy" -ForegroundColor Green

                        $PostSet = Get-ADUser -Identity $Guid -Properties DisplayName, Mail, TargetAddress, MailNickName, ProxyAddresses

                        [PSCustomObject]@{
                            Time                  = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                            Result                = 'SUCCESS'
                            Action                = 'SET'
                            Object                = 'ADUSER'
                            DisplayName           = $PostSet.DisplayName
                            UserPrincipalName     = $PostSet.UserPrincipalName
                            Mail                  = $PostSet.Mail
                            TargetAddress         = $PostSet.TargetAddress
                            MailNickName          = $PostSet.MailNickName
                            ProxyAddresses        = [string]::join('|', [String[]]$PostSet.ProxyAddresses -ne '')
                            ProposedMail          = $NewMail
                            ProposedTargetAddress = $TargetAddress
                            ProposedMailNickName  = $MailNickName
                            ProposedProxyAddress  = $PrimaryProxy
                            Guid                  = $Guid
                            FullNameError         = 'SUCCESS'
                            Message               = 'SUCCESS'
                            ExtendedMessage       = 'SUCCESS'

                        } | Export-Csv -Path $Log -NoTypeInformation -Append -Encoding UTF8
                    }
                    else {
                        Write-Host "FAILED TO FIND AD USER:`t$DisplayName" -ForegroundColor Red

                        [PSCustomObject]@{
                            Time                  = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                            Result                = 'USERNOTFOUND'
                            Action                = 'GET'
                            Object                = 'ADUSER'
                            DisplayName           = $DisplayName
                            UserPrincipalName     = $UPN
                            Mail                  = 'USERNOTFOUND'
                            TargetAddress         = 'USERNOTFOUND'
                            MailNickName          = 'USERNOTFOUND'
                            ProxyAddresses        = 'USERNOTFOUND'
                            ProposedMail          = $NewMail
                            ProposedTargetAddress = $TargetAddress
                            ProposedMailNickName  = $MailNickName
                            ProposedProxyAddress  = $PrimaryProxy
                            Guid                  = $ObjectGuid
                            FullNameError         = 'USERNOTFOUND'
                            Message               = 'USERNOTFOUND'
                            ExtendedMessage       = 'USERNOTFOUND'

                        } | Export-Csv -Path $Log -NoTypeInformation -Append -Encoding UTF8
                    }
                }
                catch {
                    Write-Host "FAILED (CHECK LOGS):`t$DisplayName" -ForegroundColor Red

                    [PSCustomObject]@{
                        Time                  = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                        Result                = 'FAILED'
                        Action                = 'REPLACE'
                        Object                = 'ADATTRIBUTES'
                        DisplayName           = $DisplayName
                        UserPrincipalName     = $UPN
                        Mail                  = 'FAILED'
                        TargetAddress         = 'FAILED'
                        MailNickName          = 'FAILED'
                        ProxyAddresses        = 'FAILED'
                        ProposedMail          = $NewMail
                        ProposedTargetAddress = $TargetAddress
                        ProposedMailNickName  = $MailNickName
                        ProposedProxyAddress  = $PrimaryProxy
                        Guid                  = $ObjectGuid
                        FullNameError         = $_.Exception.GetType().fullname
                        Message               = $_.CategoryInfo.Reason
                        ExtendedMessage       = $_.Exception.Message

                    } | Export-Csv -Path $Log -NoTypeInformation -Append -Encoding UTF8
                }
            }
        }
    }
    end {

    }
}
