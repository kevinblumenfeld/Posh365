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
        try {
            if ($Choice.SourceType -like '*Mailbox') {
                $PrePrimaryChange = Get-Mailbox -Identity $Choice.TargetId
                $CurrentPrimary = 'SMTP:{0}' -f $PrePrimaryChange.PrimarySmtpAddress
                Set-Mailbox -Identity $Choice.TargetId -EmailAddresses @{
                    Remove = $CurrentPrimary
                    Add    = $Choice.SourcePrimarySmtpAddress
                }
                $PostPrimaryChange = Get-Mailbox -Identity $Choice.TargetId
            }
            elseif ($Choice.SourceType -eq 'MailUser') {
                $PrePrimaryChange = Get-MailUser -Identity $Choice.TargetId
                Set-MailUser -Identity $Choice.TargetId -PrimarySmtpAddress $Choice.SourcePrimarySmtpAddress
                $PostPrimaryChange = Get-MailUser -Identity $Choice.TargetId
            }
            [PSCustomObject]@{
                Num                              = '[{0} of {1}]' -f $iUP, $Count
                Action                           = 'CHANGEUPN'
                Log                              = 'SUCCESS'
                Time                             = $Time
                DisplayName                      = $Choice.DisplayName
                SourceType                       = $Choice.SourceType
                ChangeRequested                  = $Choice.PrimarySmtpAddress
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
                SourceId                         = $Choice.ExternalDirectoryObjectId
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
            [PSCustomObject]@{
                Num                              = '[{0} of {1}]' -f $iUP, $Count
                Action                           = 'CHANGEUPN'
                Log                              = 'FAILED'
                Time                             = $Time
                DisplayName                      = $Choice.DisplayName
                SourceType                       = $Choice.SourceType
                ChangeRequested                  = $Choice.PrimarySmtpAddress
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
                SourceId                         = $Choice.ExternalDirectoryObjectId
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
        try {
            if ($Choice.SourceType -like '*Mailbox') {
                $PreUPNChange = Get-Mailbox -Identity $Choice.TargetId
                Set-Mailbox -Identity $Choice.TargetId -MicrosoftOnlineServicesID $Choice.SourceUserPrincipalName
                $PostUPNChange = Get-Mailbox -Identity $Choice.TargetId
            }
            elseif ($Choice.SourceType -eq 'MailUser') {
                $PreUPNChange = Get-MailUser -Identity $Choice.TargetId
                Set-MailUser -Identity $Choice.TargetId -PrimarySmtpAddress $Choice.SourcePrimarySmtpAddress
                $PostUPNChange = Get-MailUser -Identity $Choice.TargetId
            }
            [PSCustomObject]@{
                Num                              = '[{0} of {1}]' -f $iUP, $Count
                Action                           = 'ADDPRIMARY'
                Log                              = 'SUCCESS'
                Time                             = $Time
                DisplayName                      = $Choice.DisplayName
                SourceType                       = $Choice.SourceType
                ChangeRequested                  = $Choice.SourcePrimarySmtpAddress
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
                SourceId                         = $Choice.ExternalDirectoryObjectId
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
            [PSCustomObject]@{
                Num                              = '[{0} of {1}]' -f $iUP, $Count
                Action                           = 'ADDPRIMARY'
                Log                              = 'FAILED'
                Time                             = $Time
                DisplayName                      = $Choice.DisplayName
                SourceType                       = $Choice.SourceType
                ChangeRequested                  = $Choice.SourcePrimarySmtpAddress
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
                SourceId                         = $Choice.ExternalDirectoryObjectId
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
        try {
            if ($Choice.SourceType -like '*Mailbox') {
                $PremEmailChange = Get-Mailbox -Identity $Choice.TargetId
            }
            elseif ($Choice.SourceType -eq 'MailUser') {
                $PremEmailChange = Get-MailUser -Identity $Choice.TargetId
            }
            $smtpList = $null
            $smtpList = $Choice.SourceEmailAddresses -split '\|' -clike 'smtp:*'
            foreach ($smtp in $smtpList) {
                if ($Choice.SourceType -like '*Mailbox') {
                    Set-Mailbox -Identity $Choice.TargetId -EmailAddresses @{Add = $smtp }
                    $PostEmailChange = Get-Mailbox -Identity $Choice.TargetId
                }
                elseif ($Choice.SourceType -eq 'MailUser') {
                    Set-MailUser -Identity $Choice.TargetId -EmailAddresses @{Add = $smtp }
                    $PostEmailChange = Get-Mailbox -Identity $Choice.TargetId
                }
                [PSCustomObject]@{
                    Num                              = '[{0} of {1}]' -f $iUP, $Count
                    Action                           = 'ADDSECONDARY'
                    Log                              = 'SUCCESS'
                    Time                             = $Time
                    DisplayName                      = $Choice.DisplayName
                    SourceType                       = $Choice.SourceType
                    ChangeRequested                  = $smtp
                    PreChange                        = $PremEmailChange.UserPrincipalName
                    PostChange                       = $PostEmailChange.UserPrincipalName
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
                    SourceId                         = $Choice.ExternalDirectoryObjectId
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
            [PSCustomObject]@{
                Num                              = '[{0} of {1}]' -f $iUP, $Count
                Action                           = 'ADDSECONDARY'
                Log                              = 'FAILED'
                Time                             = $Time
                DisplayName                      = $Choice.DisplayName
                SourceType                       = $Choice.SourceType
                ChangeRequested                  = $smtp
                PreChange                        = $PremEmailChange.PrimarySMTPAddress
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
                SourceId                         = $Choice.ExternalDirectoryObjectId
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
    $ErrorActionPreference = 'continue'
}
