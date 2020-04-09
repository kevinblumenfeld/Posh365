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
    $i = 0

    foreach ($Recipient in $RecipientList) {
        $ADUser = Get-ADUser -identity $Recipient.SamAccountName -Properties DisplayName
        if ($Recipient.RecipientTypeDetails -like "Remote*") {
            Write-Host ('ADUpn {0} Key {1}' -f $ADUser.UserPrincipalName, $ExoHash.ContainsKey("$($ADUser.UserPrincipalName)")) -ForegroundColor Cyan
            Write-Host ('AD {0} Rec {1} Type {2}' -f $ADUser.Displayname, $Recipient.SamAccountName, $Recipient.RecipientTypeDetails) -ForegroundColor White
            [PSCustomObject]@{
                Displayname        = $ADUser.Displayname
                PrimarySmtpAddress = $Recipient.PrimarySmtpAddress
                SamAccountname     = $Recipient.SamAccountName
                OU                 = Convert-DistinguishedToCanonical -DistinguishedName ($ADUser.DistinguishedName -replace '^.+?,(?=(OU|CN)=)')
                ADUPN              = $ADUser.UserPrincipalName
                MailboxLocation    = 'CLOUD'
                MailboxType        = $Recipient.RecipientTypeDetails
                OnPremExchangGuid  = $Recipient.ExchangeGuid
                OnlineGuid         = $ExoHash[$ADUser.UserPrincipalName]['ExchangeGuid']
                OnPremArchiveGuid  = $Recipient.ArchiveGuid
                OnlineArchiveGuid  = $ExoHash[$ADUser.UserPrincipalName]['ArchiveGuid']
                MailboxGuidMatch   = $Recipient.ExchangeGuid -eq $ExoHash[$ADUser.UserPrincipalName]['ExchangeGuid']
                ArchiveGuidMatch   = $Recipient.ArchiveGuid -eq $ExoHash[$ADUser.UserPrincipalName]['ArchiveGuid']
                OnPremSid          = $ADUser.SID
            }
        }
        else {
            Write-Host ('CLOUDADUpn {0} Key {1}' -f $ADUser.UserPrincipalName, $Hash.ContainsKey("$($ADUser.UserPrincipalName)")) -ForegroundColor Green
            Write-Host ('AD {0} Rec {1} Type {2}' -f $ADUser.Displayname, $Recipient.SamAccountName, $Recipient.RecipientTypeDetails) -ForegroundColor White
            [PSCustomObject]@{
                DisplayName        = $ADUser.Displayname
                PrimarySmtpAddress = $Recipient.PrimarySmtpAddress
                SamAccountname     = $Recipient.SamAccountName
                OU                 = Convert-DistinguishedToCanonical -DistinguishedName ($ADUser.DistinguishedName -replace '^.+?,(?=(OU|CN)=)')
                ADUPN              = $ADUser.UserPrincipalName
                MailboxLocation    = 'ONPREMISES'
                MailboxType        = $Recipient.RecipientTypeDetails
                OnPremExchangGuid  = $Recipient.ExchangeGuid
                OnlineGuid         = $Hash[$ADUser.UserPrincipalName]['ExchangeGuid']
                OnPremArchiveGuid  = $Recipient.ArchiveGuid
                OnlineArchiveGuid  = $Hash[$ADUser.UserPrincipalName]['ArchiveGuid']
                MailboxGuidMatch   = $Recipient.ExchangeGuid -eq $Hash[$ADUser.UserPrincipalName]['ExchangeGuid']
                ArchiveGuidMatch   = $Recipient.ArchiveGuid -eq $Hash[$ADUser.UserPrincipalName]['ArchiveGuid']
                OnPremSid          = $ADUser.SID
            }
        }
        $i ++
        Write-Progress -Activity "$i 'out' $($RecipientList.count)" -PercentComplete ($i / $RecipientList.count * 100)
    }
}