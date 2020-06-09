function Invoke-SetMailboxFlag {
    param (
        [Parameter()]
        $ELCMailboxFlags
    )

    if (-not ($null = Get-Module ActiveDirectory -ListAvailable)) {
        Write-Host "ActiveDirectory module for PowerShell not found! Please run from a computer with the ActiveDirectory module" -ForegroundColor Red
        return
    }
    Import-Module ActiveDirectory -Force

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )
    if (-not (Test-Path $PoshPath)) {
        $null = New-Item $PoshPath -type Directory -Force:$true -ErrorAction SilentlyContinue
    }
    $SourceQuotaXML = Join-Path -Path $PoshPath -ChildPath 'SourceQuotaHash.xml'

    $QuotaHash = Import-Clixml $SourceQuotaXML
    $Props = @('msDS-ExternalDirectoryObjectId', 'msExchELCMailboxFlags', 'DisplayName')
    $Count = $QuotaHash.keys.Count
    $iUP = 0
    $ChoiceList = foreach ($key in $QuotaHash.keys) {
        $iUP++
        [PSCustomObject]@{
            'Num'                            = "[$iUP of $Count]"
            'msDS-ExternalDirectoryObjectId' = $key
            'CloudDisplayName'               = $QuotaHash[$key]['DisplayName']
        }
    }
    $Choice = $ChoiceList | Out-GridView -OutputMode Multiple -Title 'Choose which AD Users to set msExchELCMailboxFlags'
    if (-not $Choice) { return }
    $iUP = 0
    $Count = $QuotaHash.keys.Count
    $Total = $Choice.'msDS-ExternalDirectoryObjectId'.count
    foreach ($Mailbox in $Choice.'msDS-ExternalDirectoryObjectId') {
        $iUP++
        $ADUser = $null
        $ADUser = Get-ADUser -LdapFilter "(msDS-ExternalDirectoryObjectId=$Mailbox)" -Properties $Props
        if ($ADUser) {
            try {
                Write-Host "$($ADUser.DisplayName) Setting msExchELCMailboxFlags to $ELCMailboxFlags   -   " -ForegroundColor White -NoNewline
                $ADUser | Set-ADUser -replace @{ msExchELCMailboxFlags = $ELCMailboxFlags } -ErrorAction Stop
                Write-Host 'SUCCESS' -ForegroundColor Green
                $Post = Get-ADUser -LdapFilter "(msDS-ExternalDirectoryObjectId=$Mailbox)" -Properties $Props
                [PSCustomObject]@{
                    'Num'                            = "[$iUP of $Total]"
                    'DisplayName'                    = $ADUser.DisplayName
                    'CloudDisplayName'               = $QuotaHash[$Mailbox]['DisplayName']
                    'Log'                            = 'SUCCESS'
                    'msDS-ExternalDirectoryObjectId' = $Mailbox
                    'BeforeChange'                   = $ADUser.msExchELCMailboxFlags
                    'AfterChange'                    = $Post.msExchELCMailboxFlags
                    'PrimarySmtpAddress'             = $QuotaHash[$Mailbox]['PrimarySmtpAddress']
                    'UserPrincipalName'              = $QuotaHash[$Mailbox]['UserPrincipalName']
                    'RecoverableItemsQuota'          = $QuotaHash[$Mailbox]['RecoverableItemsQuota']
                    'RecoverableItemsWarningQuota'   = $QuotaHash[$Mailbox]['RecoverableItemsWarningQuota']
                    'LitigationHoldEnabled'          = $QuotaHash[$Mailbox]['LitigationHoldEnabled']
                    'LitigationHoldDate'             = $QuotaHash[$Mailbox]['LitigationHoldDate']
                    'LitigationHoldOwner'            = $QuotaHash[$Mailbox]['LitigationHoldOwner']
                    'LitigationHoldDuration'         = $QuotaHash[$Mailbox]['LitigationHoldDuration']
                    'InPlaceHolds'                   = @($QuotaHash[$Mailbox]['InPlaceHolds']) -ne '' -join '|'
                }
            }
            catch {
                Write-Host "FAILED  ERROR==> $($_.Exception.Message)" -ForegroundColor Red
                [PSCustomObject]@{
                    'Num'                            = "[$iUP of $Total]"
                    'DisplayName'                    = $ADUser.DisplayName
                    'CloudDisplayName'               = $QuotaHash[$Mailbox]['DisplayName']
                    'Log'                            = $_.Exception.Message
                    'msDS-ExternalDirectoryObjectId' = $Mailbox
                    'BeforeChange'                   = $ADUser.msExchELCMailboxFlags
                    'AfterChange'                    = ''
                    'PrimarySmtpAddress'             = $QuotaHash[$Mailbox]['PrimarySmtpAddress']
                    'UserPrincipalName'              = $QuotaHash[$Mailbox]['UserPrincipalName']
                    'RecoverableItemsQuota'          = $QuotaHash[$Mailbox]['RecoverableItemsQuota']
                    'RecoverableItemsWarningQuota'   = $QuotaHash[$Mailbox]['RecoverableItemsWarningQuota']
                    'LitigationHoldEnabled'          = $QuotaHash[$Mailbox]['LitigationHoldEnabled']
                    'LitigationHoldDate'             = $QuotaHash[$Mailbox]['LitigationHoldDate']
                    'LitigationHoldOwner'            = $QuotaHash[$Mailbox]['LitigationHoldOwner']
                    'LitigationHoldDuration'         = $QuotaHash[$Mailbox]['LitigationHoldDuration']
                    'InPlaceHolds'                   = @($QuotaHash[$Mailbox]['InPlaceHolds']) -ne '' -join '|'
                }
            }
        }
        else {
            Write-Host "msDS-ExternalDirectoryObjectId: $Mailbox NOT FOUND $($QuotaHash[$Mailbox]['DisplayName'])!!" -ForegroundColor Yellow
            [PSCustomObject]@{
                'Num'                            = "[$iUP of $Total]"
                'DisplayName'                    = ''
                'CloudDisplayName'               = $QuotaHash[$Mailbox]['DisplayName']
                'Log'                            = 'msDS-ExternalDirectoryObjectId NOT FOUND'
                'msDS-ExternalDirectoryObjectId' = $Mailbox
                'BeforeChange'                   = ''
                'AfterChange'                    = ''
                'PrimarySmtpAddress'             = $QuotaHash[$Mailbox]['PrimarySmtpAddress']
                'UserPrincipalName'              = $QuotaHash[$Mailbox]['UserPrincipalName']
                'RecoverableItemsQuota'          = $QuotaHash[$Mailbox]['RecoverableItemsQuota']
                'RecoverableItemsWarningQuota'   = $QuotaHash[$Mailbox]['RecoverableItemsWarningQuota']
                'LitigationHoldEnabled'          = $QuotaHash[$Mailbox]['LitigationHoldEnabled']
                'LitigationHoldDate'             = $QuotaHash[$Mailbox]['LitigationHoldDate']
                'LitigationHoldOwner'            = $QuotaHash[$Mailbox]['LitigationHoldOwner']
                'LitigationHoldDuration'         = $QuotaHash[$Mailbox]['LitigationHoldDuration']
                'InPlaceHolds'                   = @($QuotaHash[$Mailbox]['InPlaceHolds']) -ne '' -join '|'
            }
        }
    }
}