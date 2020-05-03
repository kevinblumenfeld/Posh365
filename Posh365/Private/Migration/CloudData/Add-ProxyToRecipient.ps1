function Add-ProxyToRecipient {
    [CmdletBinding()]
    param (
        [Parameter()]
        $AddProxyList,

        [Parameter(Mandatory)]
        [ValidateSet('RemoteMailbox', 'MailContact')]
        $Type
    )
    $ErrorActionPreference = 'Stop'
    $Count = @($AddProxylist).Count
    $i = 0
    if ($Type -eq 'RemoteMailbox') {
        foreach ($Add in $AddProxyList) {
            $RMCheck, $RMPrimaryUnchanged = $null
            $i++
            $Guid = $Add.TargetGUID.ToString()
            try {
                Set-RemoteMailbox -Identity $Guid -EmailAddresses @{add = $Add.LegacyExchangeDN } -ErrorAction Stop
                $RMCheck = Get-RemoteMailbox -Identity $Guid
                $RMPrimaryUnchanged = $RMCheck.PrimarySmtpAddress -eq $Add.PrimarySmtpAddress
                Write-Host "[$i of $Count] Success Set Remote Mailbox x500 (LegacyExchangeDN) $($RMCheck.DisplayName) - PrimarySmtpAddress unchanged? " -ForegroundColor Green -NoNewline
                if ($RMPrimaryUnchanged) {
                    Write-Host $RMPrimaryUnchanged -ForegroundColor White -BackgroundColor DarkMagenta
                }
                else {
                    Write-Host $RMPrimaryUnchanged -ForegroundColor Black -BackgroundColor Yellow
                }
                [PSCustomObject]@{
                    Num                         = '[{0} of {1}]' -f $i, $Count
                    Result                      = 'SUCCESS'
                    TargetDisplayName           = $Add.TargetDisplayName
                    PreviousPrimarySmtpAddress  = $Add.PrimarySmtpAddress
                    CurrentPrimarySmtpAddress   = $RMCheck.PrimarySmtpAddress
                    PrimarySmtpAddressUnchanged = $RMPrimaryUnchanged
                    Added                       = $Add.LegacyExchangeDN
                    GUID                        = $Guid
                    Identity                    = $Add.TargetIdentity
                    SourceDisplayName           = $Add.SourceDisplayName
                    Log                         = 'SUCCESS'
                }
                if ($Add.X500) {
                    foreach ($X in ($Add.X500).split('|')) {
                        Set-RemoteMailbox -Identity $Guid -EmailAddresses @{add = $X } -ErrorAction Stop
                        Write-Host "[$i of $Count] Success Set Remote Mailbox x500 $($RMCheck.DisplayName)" -ForegroundColor Cyan
                        [PSCustomObject]@{
                            Num                         = '[{0} of {1}]' -f $i, $Count
                            Result                      = 'SUCCESS'
                            TargetDisplayName           = $Add.TargetDisplayName
                            PreviousPrimarySmtpAddress  = $Add.PrimarySmtpAddress
                            CurrentPrimarySmtpAddress   = $RMCheck.PrimarySmtpAddress
                            PrimarySmtpAddressUnchanged = 'ALREADYVALIDATED'
                            Added                       = $X
                            GUID                        = $Guid
                            Identity                    = $Add.TargetIdentity
                            SourceDisplayName           = $Add.SourceDisplayName
                            Log                         = 'SUCCESS'
                        }
                    }
                }
            }
            catch {
                Write-Host "[$i of $Count] Failed Setting Remote Mailbox x500 $($RMCheck.DisplayName) Error: $($_.Exception.Message)" -ForegroundColor Red
                [PSCustomObject]@{
                    Num                         = '[{0} of {1}]' -f $i, $Count
                    Result                      = 'FAILED'
                    TargetDisplayName           = $Add.TargetDisplayName
                    PreviousPrimarySmtpAddress  = $Add.PrimarySmtpAddress
                    CurrentPrimarySmtpAddress   = 'FAILED'
                    PrimarySmtpAddressUnchanged = 'FAILED'
                    Added                       = $X
                    GUID                        = $Guid
                    Identity                    = $Add.TargetIdentity
                    SourceDisplayName           = $Add.SourceDisplayName
                    Log                         = $_.Exception.Message
                }
            }
        }
    }
    if ($Type -eq 'MailContact') {
        foreach ($Add in $AddProxyList) {
            $ContactCheck, $ContactPrimaryUnchanged = $null
            $i++
            $Guid = ($Add.TargetGUID).ToString()
            try {
                Set-MailContact -Identity $Guid -EmailAddresses @{add = $Add.LegacyExchangeDN } -ErrorAction Stop
                $ContactCheck = Get-MailContact -Identity $Guid
                $ContactPrimaryUnchanged = $ContactCheck.PrimarySmtpAddress -eq $Add.PrimarySmtpAddress
                Write-Host "[$i of $Count] Success Set Mail Contact x500 (LegacyExchangeDN) $($ContactCheck.DisplayName) - PrimarySmtpAddress unchanged? " -ForegroundColor Green -NoNewline
                if ($ContactPrimaryUnchanged) {
                    Write-Host $ContactPrimaryUnchanged -ForegroundColor White -BackgroundColor DarkMagenta
                }
                else {
                    Write-Host $ContactPrimaryUnchanged -ForegroundColor Black -BackgroundColor Yellow
                }
                [PSCustomObject]@{
                    Num                         = '[{0} of {1}]' -f $i, $Count
                    Result                      = 'SUCCESS'
                    TargetDisplayName           = $Add.TargetDisplayName
                    PreviousPrimarySmtpAddress  = $Add.PrimarySmtpAddress
                    CurrentPrimarySmtpAddress   = $ContactCheck.PrimarySmtpAddress
                    PrimarySmtpAddressUnchanged = $ContactPrimaryUnchanged
                    Added                       = $Add.LegacyExchangeDN
                    GUID                        = $Guid
                    Identity                    = $Add.TargetIdentity
                    SourceDisplayName           = $Add.SourceDisplayName
                    Log                         = 'SUCCESS'
                }
                if ($Add.X500) {
                    foreach ($X in ($Add.X500).split('|')) {
                        Set-MailContact -Identity $Guid -EmailAddresses @{add = $X } -ErrorAction Stop
                        Write-Host "[$i of $Count] Success Set Mail Contact x500 $($RMCheck.DisplayName)" -ForegroundColor Cyan
                        [PSCustomObject]@{
                            Num                         = '[{0} of {1}]' -f $i, $Count
                            Result                      = 'SUCCESS'
                            TargetDisplayName           = $Add.TargetDisplayName
                            PrimarySmtpAddress          = $Add.PrimarySmtpAddress
                            PrimarySmtpAddressUnchanged = 'ALREADYVALIDATED'
                            Added                       = $X
                            GUID                        = $Guid
                            Identity                    = $Add.TargetIdentity
                            SourceDisplayName           = $Add.SourceDisplayName
                            Log                         = 'SUCCESS'
                        }
                    }
                }
            }
            catch {
                Write-Host "[$i of $Count] Failed Setting Mail Contact x500 $($RMCheck.DisplayName) Error: $($_.Exception.Message)" -ForegroundColor Red
                [PSCustomObject]@{
                    Num                         = '[{0} of {1}]' -f $i, $Count
                    Result                      = 'FAILED'
                    TargetDisplayName           = $Add.TargetDisplayName
                    PrimarySmtpAddress          = $Add.PrimarySmtpAddress
                    PrimarySmtpAddressUnchanged = 'FAILED'
                    Added                       = $X
                    GUID                        = $Guid
                    Identity                    = $Add.TargetIdentity
                    SourceDisplayName           = $Add.SourceDisplayName
                    Log                         = $_.Exception.Message
                }
            }
        }
    }
}
