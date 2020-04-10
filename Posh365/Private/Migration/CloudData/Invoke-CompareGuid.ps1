function Invoke-CompareGuid {
    [CmdletBinding()]
    param (
        [Parameter()]
        $OnPremExchangeServer,

        [Parameter()]
        [switch]
        $DontViewEntireForest
    )

    $MailboxSelect = @(
        'Identity', 'SamAccountName', 'UserPrincipalName'
        'WindowsEmailAddress', 'PrimarySmtpAddress'
        'ExchangeGuid', 'ArchiveGuid'
    )
    $ExoList = Get-Mailbox -ResultSize Unlimited | Select-Object $MailboxSelect

    $ExoHash = @{ }
    foreach ($Exo in $ExoList) {
        $ExoHash[$Exo.UserPrincipalName] = @{
            'Identity'            = $Exo.Identity
            'SamAccountName'      = $Exo.SamAccountName
            'WindowsEmailAddress' = $Exo.WindowsEmailAddress
            'PrimarySmtpAddress'  = $Exo.PrimarySmtpAddress
            'ExchangeGuid'        = ($Exo.ExchangeGuid).ToString()
            'ArchiveGuid'         = ($Exo.ArchiveGuid).ToString()
        }
    }

    Get-PSSession | Remove-PSSession
    Write-Host "`r`nConnecting to Exchange On-Premises $OnPremExchangeServer`r`n" -ForegroundColor Green
    Connect-Exchange -Server $OnPremExchangeServer -DontViewEntireForest:$DontViewEntireForest

    $MailboxList = Get-Mailbox -ResultSize Unlimited | Select-Object $MailboxSelect
    $Hash = @{ }
    foreach ($Mailbox in $MailboxList) {
        $Hash[$Mailbox.UserPrincipalName] = @{
            'Identity'            = $Mailbox.Identity
            'SamAccountName'      = $Mailbox.SamAccountName
            'WindowsEmailAddress' = $Mailbox.WindowsEmailAddress
            'PrimarySmtpAddress'  = $Mailbox.PrimarySmtpAddress
            'ExchangeGuid'        = ($Mailbox.ExchangeGuid).ToString()
            'ArchiveGuid'         = ($Mailbox.ArchiveGuid).ToString()
        }
    }

    $MeuList = Get-MailUser -ResultSize Unlimited | Select-Object $MailboxSelect
    foreach ($Meu in $MeuList) {
        $Hash[$Meu.UserPrincipalName] = @{
            'Identity'            = $Meu.Identity
            'SamAccountName'      = $Meu.SamAccountName
            'WindowsEmailAddress' = $Meu.WindowsEmailAddress
            'PrimarySmtpAddress'  = $Meu.PrimarySmtpAddress
            'ExchangeGuid'        = ($Meu.ExchangeGuid).ToString()
            'ArchiveGuid'         = ($Meu.ArchiveGuid).ToString()
        }
    }

    $RecipientSelect = @(
        'Identity', 'RecipientType', 'RecipientTypeDetails'
        'SamAccountName', 'UserPrincipalName', 'WindowsEmailAddress'
        'PrimarySmtpAddress', 'ExchangeGuid', 'ArchiveGuid'
    )
    $RecipientType = @(
        'UserMailbox', 'SharedMailbox', 'RoomMailbox', 'EquipmentMailbox'
        'MailUser', 'RemoteEquipmentMailbox', 'RemoteRoomMailbox'
        'RemoteSharedMailbox', 'RemoteUserMailbox'
    )
    $RecipientList = Get-Recipient -RecipientTypeDetails $RecipientType -ResultSize Unlimited | Select-Object $RecipientSelect

    Get-PSSession | Remove-PSSession
    foreach ($Recipient in $RecipientList) {
        $ADUser = Get-ADUser -identity $Recipient.SamAccountName -Properties DisplayName, UserPrincipalName
        if ($ExoHash[$ADUser.UserPrincipalName] -or $Hash[$ADUser.UserPrincipalName]) {
            if ($Recipient.RecipientTypeDetails -like "Remote*") {
                Write-Host ('{0} {1}' -f $ADUser.Displayname, $Recipient.RecipientTypeDetails) -ForegroundColor White
                [PSCustomObject]@{
                    Displayname        = if ($ADUser.DisplayName) { $ADUser.DisplayName } else { $ADUser.Name }
                    PrimarySmtpAddress = $Recipient.PrimarySmtpAddress
                    SamAccountname     = $Recipient.SamAccountName
                    OU                 = Convert-DistinguishedToCanonical -DistinguishedName ($ADUser.DistinguishedName -replace '^.+?,(?=(OU|CN)=)')
                    ADUPN              = $ADUser.UserPrincipalName
                    MailboxLocation    = 'CLOUD'
                    MailboxType        = $Recipient.RecipientTypeDetails
                    OnPremExchangeGuid = $Recipient.ExchangeGuid
                    OnlineGuid         = $ExoHash[$ADUser.UserPrincipalName]['ExchangeGuid']
                    OnPremArchiveGuid  = $Recipient.ArchiveGuid
                    OnlineArchiveGuid  = $ExoHash[$ADUser.UserPrincipalName]['ArchiveGuid']
                    MailboxGuidMatch   = $Recipient.ExchangeGuid -eq $ExoHash[$ADUser.UserPrincipalName]['ExchangeGuid']
                    ArchiveGuidMatch   = $Recipient.ArchiveGuid -eq $ExoHash[$ADUser.UserPrincipalName]['ArchiveGuid']
                    OnPremSid          = $ADUser.SID
                }
            }
            else {
                Write-Host ('{0} {1}' -f $ADUser.Displayname, $Recipient.RecipientTypeDetails) -ForegroundColor White
                [PSCustomObject]@{
                    Displayname        = if ($ADUser.DisplayName) { $ADUser.DisplayName } else { $ADUser.Name }
                    PrimarySmtpAddress = $Recipient.PrimarySmtpAddress
                    SamAccountname     = $Recipient.SamAccountName
                    OU                 = Convert-DistinguishedToCanonical -DistinguishedName ($ADUser.DistinguishedName -replace '^.+?,(?=(OU|CN)=)')
                    ADUPN              = $ADUser.UserPrincipalName
                    MailboxLocation    = 'ONPREMISES'
                    MailboxType        = $Recipient.RecipientTypeDetails
                    OnPremExchangeGuid = $Recipient.ExchangeGuid
                    OnlineGuid         = $Hash[$ADUser.UserPrincipalName]['ExchangeGuid']
                    OnPremArchiveGuid  = $Recipient.ArchiveGuid
                    OnlineArchiveGuid  = $Hash[$ADUser.UserPrincipalName]['ArchiveGuid']
                    MailboxGuidMatch   = $Recipient.ExchangeGuid -eq $Hash[$ADUser.UserPrincipalName]['ExchangeGuid']
                    ArchiveGuidMatch   = $Recipient.ArchiveGuid -eq $Hash[$ADUser.UserPrincipalName]['ArchiveGuid']
                    OnPremSid          = $ADUser.SID
                }
            }
            else {
                [PSCustomObject]@{
                    Displayname        = if ($ADUser.DisplayName) { $ADUser.DisplayName } else { $ADUser.Name }
                    PrimarySmtpAddress = $Recipient.PrimarySmtpAddress
                    SamAccountname     = $Recipient.SamAccountName
                    OU                 = Convert-DistinguishedToCanonical -DistinguishedName ($ADUser.DistinguishedName -replace '^.+?,(?=(OU|CN)=)')
                    ADUPN              = $ADUser.UserPrincipalName
                    MailboxLocation    = $Recipient.RecipientTypeDetails
                    MailboxType        = $Recipient.RecipientTypeDetails
                    OnPremExchangeGuid = $Recipient.ExchangeGuid
                    OnlineGuid         = 'NOMATCHINGOBJECT'
                    OnPremArchiveGuid  = $Recipient.ArchiveGuid
                    OnlineArchiveGuid  = 'NOMATCHINGOBJECT'
                    MailboxGuidMatch   = 'NOMATCHINGOBJECT'
                    ArchiveGuidMatch   = 'NOMATCHINGOBJECT'
                    OnPremSid          = $ADUser.SID
                }
            }
        }
    }
}