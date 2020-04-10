using namespace System.Management.Automation.Host
function Set-ExchangeGuid {
    [CmdletBinding()]
    param (

        [Parameter()]
        [ValidateScript( { Test-Path $_ })]
        $SourceFilePath,

        [Parameter()]
        $AddGuidList,

        [Parameter()]
        $OnPremExchangeServer,

        [Parameter()]
        [switch]
        $DontViewEntireForest
    )

    Get-PSSession | Remove-PSSession
    Connect-Exchange -Server $OnPremExchangeServer -DontViewEntireForest:$DontViewEntireForest

    $ErrorActionPreference = 'Stop'
    if (-not $AddGuidList) {
        $AddGuidList = Import-Csv -Path $SourceFilePath
    }

    $Yes = [ChoiceDescription]::new('&Yes', 'Set-RemoteDomain: Yes')
    $No = [ChoiceDescription]::new('&No', 'Set-RemoteDomain: No')
    $Question = 'Are you ready to stamp ExchangeGuids?'
    $Options = [ChoiceDescription[]]($Yes, $No)
    $Title = 'Please make a selection'
    $Menu = $host.ui.PromptForChoice($Title, $Question, $Options, 1)
    switch ($Menu) {
        0 {
            foreach ($AddGuid in $AddGuidList) {
                try {
                    Set-RemoteMailbox -Identity $AddGuid.ADUPN -ExchangeGuid $AddGuid.OnlineGuid -ErrorAction stop
                    $Stamped = Get-RemoteMailbox -Identity $AddGuid.ADUPN
                    Write-Host "Success setting ExchangeGuid $($Stamped.ExchangeGuid) for On-Premises Remote Mailbox $($Stamped.DisplayName)" -ForegroundColor Green
                    [PSCustomObject]@{
                        Displayname        = $AddGuid.Displayname
                        OU                 = $AddGuid.OU
                        ExchangeGuid       = $Stamped.ExchangeGuid
                        OnlineExchangeGuid = $AddGuid.OnlineGuid
                        Result             = 'SUCCESS'
                        Log                = 'SUCCESS'
                        PrimarySmtpAddress = $AddGuid.PrimarySmtpAddress
                        SamAccountname     = $AddGuid.SamAccountName
                        ADUPN              = $AddGuid.ADUPN
                        MailboxLocation    = $AddGuid.MailboxLocation
                        MailboxType        = $AddGuid.MailboxType
                        OnPremArchiveGuid  = $AddGuid.OnPremArchiveGuid
                        OnlineArchiveGuid  = $AddGuid.OnlineArchiveGuid
                        CloudGuid          = $Stamped.Guid
                        OnPremSid          = $AddGuid.OnPremSid
                    }
                }
                catch {
                    Write-Host "Failed setting ExchangeGuid $($AddGuid.OnlineGuid) for On-Premises Remote Mailbox $($AddGuid.DisplayName)" -ForegroundColor Red
                    [PSCustomObject]@{
                        Displayname        = $AddGuid.Displayname
                        OU                 = $AddGuid.OU
                        ExchangeGuid       = $AddGuid.OnPremExchangeGuid
                        OnlineExchangeGuid = $AddGuid.OnlineGuid
                        Result             = 'FAILED'
                        Log                = $_.Exception.Message
                        PrimarySmtpAddress = $AddGuid.PrimarySmtpAddress
                        SamAccountname     = $AddGuid.SamAccountName
                        ADUPN              = $AddGuid.ADUPN
                        MailboxLocation    = $AddGuid.MailboxLocation
                        MailboxType        = $AddGuid.MailboxType
                        OnPremArchiveGuid  = $AddGuid.OnPremArchiveGuid
                        OnlineArchiveGuid  = $AddGuid.OnlineArchiveGuid
                        CloudGuid          = $Stamped.Guid
                        OnPremSid          = $AddGuid.OnPremSid
                    }
                }
            }
        }
        1 { break }
    }
    $ErrorActionPreference = 'Continue'
}