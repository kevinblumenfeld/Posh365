function Invoke-CompareGuid {
    [CmdletBinding()]
    param (
        [Parameter()]
        $OnPremExchangeServer,

        [Parameter()]
        [switch]
        $DontViewEntireForest
    )

    $CloudList = Get-Mailbox -ResultSize Unlimited

    $CloudHash = @{ }
    foreach ($Cloud in $CloudList) {
        $CloudHash[$Cloud.UserPrincipalName] = @{
            'Identity'            = $Cloud.Identity
            'SamAccountName'      = $Cloud.SamAccountName
            'WindowsEmailAddress' = $Cloud.WindowsEmailAddress
            'PrimarySmtpAddress'  = $Cloud.PrimarySmtpAddress
            'ExchangeGuid'        = ($Cloud.ExchangeGuid).ToString()
            'ArchiveGuid'         = ($Cloud.ArchiveGuid).ToString()
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

    Get-PSSession | Remove-PSSession

    $Count = $MailboxList.Count
    $iUP = 0
    foreach ($Recipient in $RecipientList) {
        $iUP++
        $ADUser = Get-ADUser -identity $Recipient.SamAccountName -Properties DisplayName, UserPrincipalName
        if ($CloudHash[$ADUser.UserPrincipalName] -or $Hash[$ADUser.UserPrincipalName]) {
            if ($Recipient.RecipientTypeDetails -like "Remote*") {
                Write-Host ('[{0} of {1}] Comparing Guids {2} ({3})' -f $iUP, $count, $ADUser.Displayname, $Recipient.RecipientTypeDetails) -ForegroundColor Green
                [PSCustomObject]@{
                    Displayname        = if ($ADUser.DisplayName) { $ADUser.DisplayName } else { $ADUser.Name }
                    PrimarySmtpAddress = $Recipient.PrimarySmtpAddress
                    SamAccountname     = $Recipient.SamAccountName
                    OU                 = Convert-DistinguishedToCanonical -DistinguishedName ($ADUser.DistinguishedName -replace '^.+?,(?=(OU|CN)=)')
                    ADUPN              = $ADUser.UserPrincipalName
                    MailboxLocation    = 'CLOUD'
                    MailboxType        = $Recipient.RecipientTypeDetails
                    OnPremExchangeGuid = $Recipient.ExchangeGuid
                    OnlineGuid         = $CloudHash[$ADUser.UserPrincipalName]['ExchangeGuid']
                    OnPremArchiveGuid  = $Recipient.ArchiveGuid
                    OnlineArchiveGuid  = $CloudHash[$ADUser.UserPrincipalName]['ArchiveGuid']
                    MailboxGuidMatch   = $Recipient.ExchangeGuid -eq $CloudHash[$ADUser.UserPrincipalName]['ExchangeGuid']
                    ArchiveGuidMatch   = $Recipient.ArchiveGuid -eq $CloudHash[$ADUser.UserPrincipalName]['ArchiveGuid']
                    OnPremSid          = $ADUser.SID
                }
            }
            else {
                Write-Host ('[{0} of {1}] Comparing Guids {2} ({3})' -f $iUP, $count, $ADUser.Displayname, $Recipient.RecipientTypeDetails) -ForegroundColor Green
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
        }
        else {
            Write-Host ('[{0} of {1}] No matching {2} {3} {4}' -f $iUP, $count, $ADUser.Displayname, $ADUser.UserPrincipalName, $Recipient.RecipientTypeDetails) -ForegroundColor Red
            [PSCustomObject]@{
                Displayname        = if ($ADUser.DisplayName) { $ADUser.DisplayName } else { $ADUser.Name }
                PrimarySmtpAddress = $Recipient.PrimarySmtpAddress
                SamAccountname     = $Recipient.SamAccountName
                OU                 = Convert-DistinguishedToCanonical -DistinguishedName ($ADUser.DistinguishedName -replace '^.+?,(?=(OU|CN)=)')
                ADUPN              = $ADUser.UserPrincipalName
                MailboxLocation    = 'NOMATCHINGOBJECT'
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