function Set-ExchangeGuid {
    [CmdletBinding()]
    param (

        [Parameter()]
        [ValidateScript( { Test-Path $_ })]
        $SourceFilePath,

        [Parameter()]
        $AddGuidList
    )

    if (-not $AddGuidList) {
        $AddGuidList = Import-Csv -Path $SourceFilePath
    }

    $Yes = [ChoiceDescription]::new('&Yes', 'Set-RemoteDomain: Yes')
    $No = [ChoiceDescription]::new('&No', 'Set-RemoteDomain: No')
    $Question = 'Are you ready to stamp ExchangeGuids in this tenant... {0} ?' -f $InitialDomain
    $Options = [ChoiceDescription[]]($Yes, $No)
    $Menu = $host.ui.PromptForChoice($Title, $Question, $Options, 1)
    $ErrorActionPreference = 'Stop'
    switch ($Menu) {
        0 {
            foreach ($AddGuid in $AddGuidList) {
                try {
                    Set-RemoteMailbox -Identity $AddGuid.ADUPN -ExchangeGuid $AddGuid.OnPremExchangGuid -ErrorAction stop
                    $Stamped = Get-RemoteMailbox -Identity $AddGuid.ADUPN -ErrorAction SilentlyContinue
                    [PSCustomObject]@{
                        Displayname        = $AddGuid.Displayname
                        OU                 = $AddGuid.OU
                        ExchangGuid        = $AddGuid.OnPremExchangGuid
                        OnlineExchangeGuid = $Stamped.ExchangeGuid
                        Result             = 'SUCCESS'
                        Log                = 'SUCCESS'
                        PrimarySmtpAddress = $AddGuid.PrimarySmtpAddress
                        SamAccountname     = $AddGuid.SamAccountName
                        ADUPN              = $AddGuid.UserPrincipalName
                        MailboxLocation    = $AddGuid.MailboxLocation
                        MailboxType        = $AddGuid.MailboxType
                        OnPremArchiveGuid  = $AddGuid.OnPremArchiveGuid
                        OnlineArchiveGuid  = $AddGuid.OnlineArchiveGuid
                        OnlineGuid         = $Stamped.Guid
                        OnPremSid          = $ADUser.OnPremSid
                    }
                }
                catch {
                    [PSCustomObject]@{
                        Displayname        = $AddGuid.Displayname
                        OU                 = $AddGuid.OU
                        ExchangGuid        = $AddGuid.OnPremExchangGuid
                        OnlineExchangeGuid = $Stamped.ExchangeGuid
                        Result             = 'FAILED'
                        Log                = $_.Exception.Message
                        PrimarySmtpAddress = $AddGuid.PrimarySmtpAddress
                        SamAccountname     = $AddGuid.SamAccountName
                        ADUPN              = $AddGuid.UserPrincipalName
                        MailboxLocation    = $AddGuid.MailboxLocation
                        MailboxType        = $AddGuid.MailboxType
                        OnPremArchiveGuid  = $AddGuid.OnPremArchiveGuid
                        OnlineArchiveGuid  = $AddGuid.OnlineArchiveGuid
                        OnlineGuid         = $Stamped.Guid
                        OnPremSid          = $ADUser.OnPremSid
                    }
                }
            }
        }
        1 { break }
    }
    $ErrorActionPreference = 'Continue'
}