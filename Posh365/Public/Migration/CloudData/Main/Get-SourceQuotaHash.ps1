function Get-SourceQuotaHash {
    param (

    )
    Get-PSSession | Remove-PSSession
    Connect-ExchangeOnline

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )
    if (-not (Test-Path $PoshPath)) {
        $null = New-Item $PoshPath -type Directory -Force:$true -ErrorAction SilentlyContinue
    }
    $QuotaMailboxBackupXML = Join-Path -Path $PoshPath -ChildPath ('SourceQuota_Mailbox_Backup_{0}.xml' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))
    $SourceQuotaXML = Join-Path -Path $PoshPath -ChildPath 'SourceQuotaHash.xml'

    Get-EXOMailbox -ResultSize Unlimited -PropertySets All | Export-Clixml $QuotaMailboxBackupXML
    $MailboxList = Import-Clixml $QuotaMailboxBackupXML
    $QuotaHash = @{ }
    foreach ($Mailbox in $MailboxList) {
        $Quota = $Mailbox.RecoverableItemsQuota.split(' ')
        if ([int]$Quota[0] -gt 30 -and $Quota[1] -eq 'GB' -and $Mailbox.IsDirSynced) {
            $QuotaHash['User_{0}' -f $Mailbox.ExternalDirectoryObjectId] = @{
                'DisplayName'                  = $Mailbox.DisplayName
                'PrimarySmtpAddress'           = $Mailbox.PrimarySmtpAddress
                'UserPrincipalName'            = $Mailbox.UserPrincipalName
                'RecoverableItemsQuota'        = $Mailbox.RecoverableItemsQuota
                'RecoverableItemsWarningQuota' = $Mailbox.RecoverableItemsWarningQuota
                'LitigationHoldEnabled'        = $Mailbox.LitigationHoldEnabled
                'LitigationHoldDate'           = $Mailbox.LitigationHoldDate
                'LitigationHoldOwner'          = $Mailbox.LitigationHoldOwner
                'LitigationHoldDuration'       = $Mailbox.LitigationHoldDuration
                'InPlaceHolds'                 = $Mailbox.InPlaceHolds
            }
        }
    }
    $QuotaHash | Export-Clixml $SourceQuotaXML
}