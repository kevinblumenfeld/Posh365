function Invoke-CompleteCloudDataSync {
    [CmdletBinding()]
    param (
        [Parameter()]
        $ChoiceList
    )
    $ErrorActionPreference = 'stop'
    $Count = @($ChoiceList).Count
    $iUP = 0
    $Time = [DateTime]::Now.ToString('yyyy-MM-dd-hhmm')
    foreach ($Choice in $ChoiceList) {
        $CurrentPrimary, $PreEmailChange, $PostEmailChange, $PrePrimaryChange, $PostPrimaryChange, $PreUPNChange, $PostUPNChange, $PostPrimaryChange = $null
        $iUP++
        #Region PRIMARY CHANGE
        Write-Host ('[{0} of {1}] {2} ({3}) | PrimarySmtpAddress Change - ' -f $iUP, $Count, $Choice.DisplayName, $Choice.SourceType) -ForegroundColor Cyan -NoNewline
        try {
            if ($Choice.SourceType -like '*Mailbox') {
                $PrePrimaryChange = Get-Mailbox -Identity $Choice.TargetId
                $CurrentPrimary = 'SMTP:{0}' -f $PrePrimaryChange.PrimarySmtpAddress
                Set-Mailbox -Identity $Choice.TargetId -WarningAction SilentlyContinue -EmailAddresses @{
                    Remove = $CurrentPrimary
                    Add    = 'SMTP:{0}' -f $Choice.SourcePrimarySmtpAddress
                }
                $PostPrimaryChange = Get-Mailbox -Identity $Choice.TargetId
            }
            elseif ($Choice.SourceType -eq 'MailUser') {
                $PrePrimaryChange = Get-MailUser -Identity $Choice.TargetId
                Set-MailUser -Identity $Choice.TargetId -PrimarySmtpAddress $Choice.SourcePrimarySmtpAddress -WarningAction SilentlyContinue
                $PostPrimaryChange = Get-MailUser -Identity $Choice.TargetId
            }
            Write-Host ('SUCCESS PRIMARY FROM: {0} TO: {1}' -f $PrePrimaryChange.PrimarySMTPAddress, $PostPrimaryChange.PrimarySMTPAddress) -ForegroundColor Green
            [PSCustomObject]@{
                Num                              = '[{0} of {1}]' -f $iUP, $Count
                Action                           = 'CHANGEPRIMARY'
                Log                              = 'SUCCESS'
                Time                             = $Time
                DisplayName                      = $Choice.DisplayName
                SourceType                       = $Choice.SourceType
                ChangeRequested                  = $Choice.SourcePrimarySmtpAddress
                PreChange                        = $PrePrimaryChange.PrimarySMTPAddress
                PostChange                       = $PostPrimaryChange.PrimarySMTPAddress
                SourceEmailAddresses             = $Choice.SourceEmailAddresses
                SourcePrimarySmtpAddress         = $Choice.SourcePrimarySmtpAddress
                SourceUserPrincipalName          = $Choice.SourceUserPrincipalName
                CurrentUserPrincipalName         = $PostPrimaryChange.UserPrincipalName
                CurrentPrimarySmtpAddress        = $PostPrimaryChange.PrimarySMTPAddress
                CurrentEmailAddresses            = @($PostPrimaryChange.EmailAddresses) -ne '' -join '|'
                CurrentMicrosoftOnlineServicesID = $PostPrimaryChange.MicrosoftOnlineServicesID
                CurrentWindowsLiveID             = $PostPrimaryChange.WindowsLiveID
                CurrentWindowsEmailAddress       = $PostPrimaryChange.WindowsEmailAddress
                CurrentExternalEmailAddress      = $PostPrimaryChange.ExternalEmailAddress
                TargetId                         = $Choice.TargetId
                SourceId                         = $Choice.SourceID
                UserPrincipalName                = $Choice.UserPrincipalName
                Name                             = $Choice.Name
                MicrosoftOnlineServicesID        = $Choice.MicrosoftOnlineServicesID
                PrimarySMTPAddress               = $Choice.PrimarySMTPAddress
                Alias                            = $Choice.Alias
                ExternalEmailAddress             = $Choice.ExternalEmailAddress
                ExchangeGuid                     = $Choice.ExchangeGuid
                TargetEmailAddresses             = $Choice.TargetEmailAddresses
            }
        }
        catch {
            Write-Host "FAILED $($_.Exception.Message)" -ForegroundColor Red
            [PSCustomObject]@{
                Num                              = '[{0} of {1}]' -f $iUP, $Count
                Action                           = 'CHANGEPRIMARY'
                Log                              = $_.Exception.Message
                Time                             = $Time
                DisplayName                      = $Choice.DisplayName
                SourceType                       = $Choice.SourceType
                ChangeRequested                  = $Choice.SourcePrimarySmtpAddress
                PreChange                        = $PrePrimaryChange.PrimarySMTPAddress
                PostChange                       = 'FAILED'
                SourceEmailAddresses             = $Choice.SourceEmailAddresses
                SourcePrimarySmtpAddress         = $Choice.SourcePrimarySmtpAddress
                SourceUserPrincipalName          = $Choice.SourceUserPrincipalName
                CurrentUserPrincipalName         = 'FAILED'
                CurrentPrimarySmtpAddress        = 'FAILED'
                CurrentEmailAddresses            = 'FAILED'
                CurrentMicrosoftOnlineServicesID = 'FAILED'
                CurrentWindowsLiveID             = 'FAILED'
                CurrentWindowsEmailAddress       = 'FAILED'
                CurrentExternalEmailAddress      = 'FAILED'
                TargetId                         = $Choice.TargetId
                SourceId                         = $Choice.SourceID
                UserPrincipalName                = $Choice.UserPrincipalName
                Name                             = $Choice.Name
                MicrosoftOnlineServicesID        = $Choice.MicrosoftOnlineServicesID
                PrimarySMTPAddress               = $Choice.PrimarySMTPAddress
                Alias                            = $Choice.Alias
                ExternalEmailAddress             = $Choice.ExternalEmailAddress
                ExchangeGuid                     = $Choice.ExchangeGuid
                TargetEmailAddresses             = $Choice.TargetEmailAddresses
            }
        }
        #EndRegion PRIMARY CHANGE
        #Region UPN CHANGE
        Write-Host ('[{0} of {1}] {2} ({3}) | UPN Change - ' -f $iUP, $Count, $Choice.DisplayName, $Choice.SourceType) -ForegroundColor Cyan -NoNewline
        try {
            if ($Choice.SourceType -like '*Mailbox') {
                $PreUPNChange = Get-Mailbox -Identity $Choice.TargetId
                Set-Mailbox -Identity $Choice.TargetId -MicrosoftOnlineServicesID $Choice.SourceUserPrincipalName -WarningAction SilentlyContinue
                $PostUPNChange = Get-Mailbox -Identity $Choice.TargetId
            }
            elseif ($Choice.SourceType -eq 'MailUser') {
                $PreUPNChange = Get-MailUser -Identity $Choice.TargetId
                Set-MailUser -Identity $Choice.TargetId -PrimarySmtpAddress $Choice.SourcePrimarySmtpAddress -WarningAction SilentlyContinue
                $PostUPNChange = Get-MailUser -Identity $Choice.TargetId
            }
            Write-Host ('SUCCESS UPN FROM: {0} TO: {1}' -f $PreUPNChange.UserPrincipalName, $PostUPNChange.UserPrincipalName) -ForegroundColor Green
            [PSCustomObject]@{
                Num                              = '[{0} of {1}]' -f $iUP, $Count
                Action                           = 'UPNCHANGE'
                Log                              = 'SUCCESS'
                Time                             = $Time
                DisplayName                      = $Choice.DisplayName
                SourceType                       = $Choice.SourceType
                ChangeRequested                  = $Choice.SourceUserPrincipalName
                PreChange                        = $PreUPNChange.UserPrincipalName
                PostChange                       = $PostUPNChange.UserPrincipalName
                SourceEmailAddresses             = $Choice.SourceEmailAddresses
                SourcePrimarySmtpAddress         = $Choice.SourcePrimarySmtpAddress
                SourceUserPrincipalName          = $Choice.SourceUserPrincipalName
                CurrentUserPrincipalName         = $PostUPNChange.UserPrincipalName
                CurrentPrimarySmtpAddress        = $PostUPNChange.PrimarySMTPAddress
                CurrentEmailAddresses            = @($PostUPNChange.EmailAddresses) -ne '' -join '|'
                CurrentMicrosoftOnlineServicesID = $PostUPNChange.MicrosoftOnlineServicesID
                CurrentWindowsLiveID             = $PostUPNChange.WindowsLiveID
                CurrentWindowsEmailAddress       = $PostUPNChange.WindowsEmailAddress
                CurrentExternalEmailAddress      = $PostUPNChange.ExternalEmailAddress
                TargetId                         = $Choice.TargetId
                SourceId                         = $Choice.SourceID
                UserPrincipalName                = $Choice.UserPrincipalName
                Name                             = $Choice.Name
                MicrosoftOnlineServicesID        = $Choice.MicrosoftOnlineServicesID
                PrimarySMTPAddress               = $Choice.PrimarySMTPAddress
                Alias                            = $Choice.Alias
                ExternalEmailAddress             = $Choice.ExternalEmailAddress
                ExchangeGuid                     = $Choice.ExchangeGuid
                TargetEmailAddresses             = $Choice.TargetEmailAddresses
            }
        }
        catch {
            Write-Host "FAILED $($_.Exception.Message)" -ForegroundColor Red
            [PSCustomObject]@{
                Num                              = '[{0} of {1}]' -f $iUP, $Count
                Action                           = 'UPNCHANGE'
                Log                              = $_.Exception.Message
                Time                             = $Time
                DisplayName                      = $Choice.DisplayName
                SourceType                       = $Choice.SourceType
                ChangeRequested                  = $Choice.UserPrincipalName
                PreChange                        = $PreUPNChange.PrimarySMTPAddress
                PostChange                       = 'FAILED'
                SourceEmailAddresses             = $Choice.SourceEmailAddresses
                SourcePrimarySmtpAddress         = $Choice.SourcePrimarySmtpAddress
                SourceUserPrincipalName          = $Choice.SourceUserPrincipalName
                CurrentUserPrincipalName         = 'FAILED'
                CurrentPrimarySmtpAddress        = 'FAILED'
                CurrentEmailAddresses            = 'FAILED'
                CurrentMicrosoftOnlineServicesID = 'FAILED'
                CurrentWindowsLiveID             = 'FAILED'
                CurrentWindowsEmailAddress       = 'FAILED'
                CurrentExternalEmailAddress      = 'FAILED'
                TargetId                         = $Choice.TargetId
                SourceId                         = $Choice.SourceID
                UserPrincipalName                = $Choice.UserPrincipalName
                Name                             = $Choice.Name
                MicrosoftOnlineServicesID        = $Choice.MicrosoftOnlineServicesID
                PrimarySMTPAddress               = $Choice.PrimarySMTPAddress
                Alias                            = $Choice.Alias
                ExternalEmailAddress             = $Choice.ExternalEmailAddress
                ExchangeGuid                     = $Choice.ExchangeGuid
                TargetEmailAddresses             = $Choice.TargetEmailAddresses
            }
        }
        #EndRegion UPN CHANGE
        #Region SECONDARY EMAILS CHANGE
        Write-Host ('[{0} of {1}] {2} ({3}) | Secondary Adds - ' -f $iUP, $Count, $Choice.DisplayName, $Choice.SourceType) -ForegroundColor Cyan -NoNewline
        try {
            if ($Choice.SourceType -like '*Mailbox') {
                $PreEmailChange = Get-Mailbox -Identity $Choice.TargetId
            }
            elseif ($Choice.SourceType -eq 'MailUser') {
                $PreEmailChange = Get-MailUser -Identity $Choice.TargetId
            }
            $smtpList = $null
            $smtpList = $Choice.SourceEmailAddresses -split '\|' -clike 'smtp:*'
            foreach ($smtp in $smtpList) {
                if ($Choice.SourceType -like '*Mailbox') {
                    Set-Mailbox -Identity $Choice.TargetId -EmailAddresses @{Add = $smtp } -WarningAction SilentlyContinue
                    $PostEmailChange = Get-Mailbox -Identity $Choice.TargetId
                }
                elseif ($Choice.SourceType -eq 'MailUser') {
                    Set-MailUser -Identity $Choice.TargetId -EmailAddresses @{Add = $smtp }
                    $PostEmailChange = Get-Mailbox -Identity $Choice.TargetId
                }
                Write-Host ('SUCCESS SECONDARY ADD: {0} Added: {1}' -f $smtp, $smtp -in $PostEmailChange.EmailAddresses) -ForegroundColor Green
                [PSCustomObject]@{
                    Num                              = '[{0} of {1}]' -f $iUP, $Count
                    Action                           = 'ADDSECONDARY'
                    Log                              = 'SUCCESS'
                    Time                             = $Time
                    DisplayName                      = $Choice.DisplayName
                    SourceType                       = $Choice.SourceType
                    ChangeRequested                  = $smtp
                    PreChange                        = @($PreEmailChange.EmailAddresses) -ne '' -join '|'
                    PostChange                       = @($PostEmailChange.EmailAddresses) -ne '' -join '|'
                    SourceEmailAddresses             = $Choice.SourceEmailAddresses
                    SourcePrimarySmtpAddress         = $Choice.SourcePrimarySmtpAddress
                    SourceUserPrincipalName          = $Choice.SourceUserPrincipalName
                    CurrentUserPrincipalName         = $PostEmailChange.UserPrincipalName
                    CurrentPrimarySmtpAddress        = $PostEmailChange.PrimarySMTPAddress
                    CurrentEmailAddresses            = @($PostEmailChange.EmailAddresses) -ne '' -join '|'
                    CurrentMicrosoftOnlineServicesID = $PostEmailChange.MicrosoftOnlineServicesID
                    CurrentWindowsLiveID             = $PostEmailChange.WindowsLiveID
                    CurrentWindowsEmailAddress       = $PostEmailChange.WindowsEmailAddress
                    CurrentExternalEmailAddress      = $PostEmailChange.ExternalEmailAddress
                    TargetId                         = $Choice.TargetId
                    SourceId                         = $Choice.SourceID
                    UserPrincipalName                = $Choice.UserPrincipalName
                    Name                             = $Choice.Name
                    MicrosoftOnlineServicesID        = $Choice.MicrosoftOnlineServicesID
                    PrimarySMTPAddress               = $Choice.PrimarySMTPAddress
                    Alias                            = $Choice.Alias
                    ExternalEmailAddress             = $Choice.ExternalEmailAddress
                    ExchangeGuid                     = $Choice.ExchangeGuid
                    TargetEmailAddresses             = $Choice.TargetEmailAddresses
                }
            }
        }
        catch {
            Write-Host "FAILED $($_.Exception.Message)" -ForegroundColor Red
            [PSCustomObject]@{
                Num                              = '[{0} of {1}]' -f $iUP, $Count
                Action                           = 'ADDSECONDARY'
                Log                              = $_.Exception.Message
                Time                             = $Time
                DisplayName                      = $Choice.DisplayName
                SourceType                       = $Choice.SourceType
                ChangeRequested                  = $smtp
                PreChange                        = @($PreEmailChange.EmailAddresses) -ne '' -join '|'
                PostChange                       = 'FAILED'
                SourceEmailAddresses             = $Choice.SourceEmailAddresses
                SourcePrimarySmtpAddress         = $Choice.SourcePrimarySmtpAddress
                SourceUserPrincipalName          = $Choice.SourceUserPrincipalName
                CurrentUserPrincipalName         = 'FAILED'
                CurrentPrimarySmtpAddress        = 'FAILED'
                CurrentEmailAddresses            = 'FAILED'
                CurrentMicrosoftOnlineServicesID = 'FAILED'
                CurrentWindowsLiveID             = 'FAILED'
                CurrentWindowsEmailAddress       = 'FAILED'
                CurrentExternalEmailAddress      = 'FAILED'
                TargetId                         = $Choice.TargetId
                SourceId                         = $Choice.SourceID
                UserPrincipalName                = $Choice.UserPrincipalName
                Name                             = $Choice.Name
                MicrosoftOnlineServicesID        = $Choice.MicrosoftOnlineServicesID
                PrimarySMTPAddress               = $Choice.PrimarySMTPAddress
                Alias                            = $Choice.Alias
                ExternalEmailAddress             = $Choice.ExternalEmailAddress
                ExchangeGuid                     = $Choice.ExchangeGuid
                TargetEmailAddresses             = $Choice.TargetEmailAddresses
            }
        }
        #EndRegion SECONDARY EMAILS CHANGE
    }
    $ErrorActionPreference = 'continue'
}
