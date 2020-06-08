function Invoke-SetMailboxFlag {
    param (
        [Parameter()]
        $ELCMailboxFlags
    )

    if (-not ($null = Get-Module ActiveDirectory -ListAvailable)) {
        Write-Host "ActiveDirectory module for PowerShell not found! Please run from a computer with the ActiveDirectory module"
        return
    }
    Import-Module ActiveDirectory -Force

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )
    if (-not (Test-Path $PoshPath)) {
        $null = New-Item $PoshPath -type Directory -Force:$true -ErrorAction SilentlyContinue
    }
    $SourceQuotaXML = Join-Path -Path $PoshPath -ChildPath 'SourceQuota.xml'

    $QuotaHash = Import-Clixml $SourceQuotaXML
    $Props = @('msDS-ExternalDirectoryObjectId', 'msExchELCMailboxFlags', 'DisplayName')
    foreach ($Mailbox in $QuotaHash.keys) {
        $ADUser = $null
        $ADUser = Get-ADUser -LdapFilter "(msDS-ExternalDirectoryObjectId=$Mailbox)" -Properties $Props

        if ($ADUser) {
            try {
                Write-Host "$($ADUser.DisplayName) Setting msExchELCMailboxFlags to $ELCMailboxFlags   -   " -ForegroundColor White -NoNewline
                $ADUser | Set-ADUser -replace @{ msExchELCMailboxFlags = $ELCMailboxFlags } -ErrorAction Stop
                Write-Host 'SUCCESS' -ForegroundColor Green
                $Post = Get-ADUser -LdapFilter "(msDS-ExternalDirectoryObjectId=$Mailbox)" -Properties $Props
                [PSCustomObject]@{
                    'DisplayName'                    = $ADUser.DisplayName
                    'CloudDisplayName'               = $QuotaHash[$Mailbox]['DisplayName']
                    'Log'                            = 'SUCCESS'
                    'msDS-ExternalDirectoryObjectId' = $Mailbox
                    'BeforeChange'                   = $ADUser.msExchELCMailboxFlags
                    'AfterChange'                    = $Post.msExchELCMailboxFlags
                    'PrimarySmtpAddress'             = $QuotaHash[$Mailbox]['PrimarySmtpAddress']
                    'UserPrincipalName'              = $QuotaHash[$Mailbox]['UserPrincipalName']
                }
            }
            catch {
                Write-Host "FAILED  ERROR==> $($_.Exception.Message)" -ForegroundColor Red
                [PSCustomObject]@{
                    'DisplayName'                    = $ADUser.DisplayName
                    'CloudDisplayName'               = $QuotaHash[$Mailbox]['DisplayName']
                    'Log'                            = $_.Exception.Message
                    'msDS-ExternalDirectoryObjectId' = $Mailbox
                    'BeforeChange'                   = $ADUser.msExchELCMailboxFlags
                    'AfterChange'                    = ''
                    'PrimarySmtpAddress'             = $QuotaHash[$Mailbox]['PrimarySmtpAddress']
                    'UserPrincipalName'              = $QuotaHash[$Mailbox]['UserPrincipalName']
                }
            }
        }
        else {
            Write-Host "msDS-ExternalDirectoryObjectId: $Mailbox NOT FOUND $($QuotaHash[$Mailbox]['DisplayName'])!!" -ForegroundColor Yellow
            [PSCustomObject]@{
                'DisplayName'                    = ''
                'CloudDisplayName'               = $QuotaHash[$Mailbox]['DisplayName']
                'Log'                            = 'msDS-ExternalDirectoryObjectId NOT FOUND'
                'msDS-ExternalDirectoryObjectId' = $Mailbox
                'BeforeChange'                   = ''
                'AfterChange'                    = ''
                'PrimarySmtpAddress'             = $QuotaHash[$Mailbox]['PrimarySmtpAddress']
                'UserPrincipalName'              = $QuotaHash[$Mailbox]['UserPrincipalName']
            }
        }
    }
}