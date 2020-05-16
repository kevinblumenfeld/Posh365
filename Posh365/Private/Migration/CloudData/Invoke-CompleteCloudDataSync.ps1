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
        $PostUPNChange, $PostSmtpChange = $null
        $iUP++
        if ($Choice.Property -eq 'UserPrincipalName') {
            try {
                Set-MsolUserPrincipalName -ObjectId $Choice.TargetId -NewUserPrincipalName $Choice.SourceUserPrincipalName
                if ($Choice.SourceType -like '*Mailbox') {
                    $PostUPNChange = Get-Mailbox -Identity $Choice.TargetId
                }
                elseif ($Choice.SourceType -eq 'MailUser') {
                    $PostUPNChange = Get-MailUser -Identity $Choice.TargetId
                }
                [PSCustomObject]@{
                    Num                       = '[{0} of {1}]' -f $iUP, $Count
                    Time                      = $Time
                    DisplayName               = $Choice.DisplayName
                    Action                    = 'SETUSERPRINCIPALNAME'
                    Log                       = 'SUCCESS'
                    LogTime                   = $Choice.Time
                    ResultNew                 = $Choice.ResultNew
                    ResultSet                 = $Choice.ResultSet
                    SourceType                = $Choice.SourceType
                    Property                  = 'UserPrincipalName'
                    SourceUserPrincipalName   = $Choice.SourceUserPrincipalName
                    CurrentUserPrincipalName  = $PostUPNChange.UserPrincipalName
                    smtp                      = ''
                    CurrentEmailAddresses     = @($PostUPNChange) -ne '' -join '|'
                    TargetId                  = $Choice.TargetId
                    SourceEmailAddresses      = $Choice.SourceEmailAddresses
                    SourcePrimarySmtpAddress  = $Choice.SourcePrimarySmtpAddress
                    UserPrincipalName         = $Choice.UserPrincipalName
                    Name                      = $Choice.Name
                    MicrosoftOnlineServicesID = $Choice.PrimarySmtpAddress
                    PrimarySMTPAddress        = $Choice.PrimarySMTPAddress
                    Alias                     = $Choice.Alias
                    ExternalEmailAddress      = $Choice.ExternalEmailAddress
                    ExchangeGuid              = $Choice.ExchangeGuid
                    SourceId                  = $Choice.ExternalDirectoryObjectId
                    TargetEmailAddresses      = $Choice.TargetEmailAddresses
                }
            }
            catch {
                [PSCustomObject]@{
                    Num                       = '[{0} of {1}]' -f $iUP, $Count
                    Time                      = $Time
                    DisplayName               = $Choice.DisplayName
                    Action                    = 'SETUSERPRINCIPALNAME'
                    Log                       = $_.Exception.Message
                    LogTime                   = $Choice.Time
                    ResultNew                 = $Choice.ResultNew
                    ResultSet                 = $Choice.ResultSet
                    SourceType                = $Choice.SourceType
                    Property                  = 'UserPrincipalName'
                    SourceUserPrincipalName   = $Choice.SourceUserPrincipalName
                    CurrentUserPrincipalName  = ''
                    smtp                      = ''
                    CurrentEmailAddresses     = ''
                    TargetId                  = $Choice.TargetId
                    SourceEmailAddresses      = $Choice.SourceEmailAddresses
                    SourcePrimarySmtpAddress  = $Choice.SourcePrimarySmtpAddress
                    UserPrincipalName         = $Choice.UserPrincipalName
                    Name                      = $Choice.Name
                    MicrosoftOnlineServicesID = $Choice.PrimarySmtpAddress
                    PrimarySMTPAddress        = $Choice.PrimarySMTPAddress
                    Alias                     = $Choice.Alias
                    ExternalEmailAddress      = $Choice.ExternalEmailAddress
                    ExchangeGuid              = $Choice.ExchangeGuid
                    SourceId                  = $Choice.ExternalDirectoryObjectId
                    TargetEmailAddresses      = $Choice.TargetEmailAddresses
                }
            }
        }
        if ($Choice.Property -eq 'smtp') {
            try {
                if ($Choice.SourceType -like '*Mailbox') {
                    Set-Mailbox -Identity $Choice.TargetId -EmailAddresses @{ add = $Choice.smtp }
                    $PostSmtpChange = Get-Mailbox -Identity $Choice.TargetId
                }
                elseif ($Type -eq 'MailUser') {
                    Set-MailUser -Identity $Choice.TargetId -EmailAddresses @{ add = $Choice.smtp }
                    $PostSmtpChange = Get-MailUser -Identity $Choice.TargetId
                }
                [PSCustomObject]@{
                    Num                       = '[{0} of {1}]' -f $iUP, $Count
                    Time                      = $Time
                    DisplayName               = $Choice.DisplayName
                    Action                    = 'ADDSMTP'
                    Log                       = 'SUCCESS'
                    LogTime                   = $Choice.Time
                    ResultNew                 = $Choice.ResultNew
                    ResultSet                 = $Choice.ResultSet
                    SourceType                = $Choice.SourceType
                    Property                  = 'UserPrincipalName'
                    SourceUserPrincipalName   = $Choice.SourceUserPrincipalName
                    CurrentUserPrincipalName  = $PostUPNChange.UserPrincipalName
                    smtp                      = ''
                    CurrentEmailAddresses     = @($PostSmtpChange.EmailAddresses) -ne '' -join '|'
                    TargetId                  = $Choice.TargetId
                    SourceEmailAddresses      = $Choice.SourceEmailAddresses
                    SourcePrimarySmtpAddress  = $Choice.SourcePrimarySmtpAddress
                    UserPrincipalName         = $Choice.UserPrincipalName
                    Name                      = $Choice.Name
                    MicrosoftOnlineServicesID = $Choice.PrimarySmtpAddress
                    PrimarySMTPAddress        = $Choice.PrimarySMTPAddress
                    Alias                     = $Choice.Alias
                    ExternalEmailAddress      = $Choice.ExternalEmailAddress
                    ExchangeGuid              = $Choice.ExchangeGuid
                    SourceId                  = $Choice.ExternalDirectoryObjectId
                    TargetEmailAddresses      = $Choice.TargetEmailAddresses
                }
            }
            catch {
                [PSCustomObject]@{
                    Num                       = '[{0} of {1}]' -f $iUP, $Count
                    Time                      = $Time
                    DisplayName               = $Choice.DisplayName
                    Action                    = 'ADDSMTP'
                    Log                       = $_.Exception.Message
                    LogTime                   = $Choice.Time
                    ResultNew                 = $Choice.ResultNew
                    ResultSet                 = $Choice.ResultSet
                    SourceType                = $Choice.SourceType
                    Property                  = 'UserPrincipalName'
                    SourceUserPrincipalName   = $Choice.SourceUserPrincipalName
                    CurrentUserPrincipalName  = ''
                    smtp                      = ''
                    CurrentEmailAddresses     = ''
                    TargetId                  = $Choice.TargetId
                    SourceEmailAddresses      = $Choice.SourceEmailAddresses
                    SourcePrimarySmtpAddress  = $Choice.SourcePrimarySmtpAddress
                    UserPrincipalName         = $Choice.UserPrincipalName
                    Name                      = $Choice.Name
                    MicrosoftOnlineServicesID = $Choice.PrimarySmtpAddress
                    PrimarySMTPAddress        = $Choice.PrimarySMTPAddress
                    Alias                     = $Choice.Alias
                    ExternalEmailAddress      = $Choice.ExternalEmailAddress
                    ExchangeGuid              = $Choice.ExchangeGuid
                    SourceId                  = $Choice.ExternalDirectoryObjectId
                    TargetEmailAddresses      = $Choice.TargetEmailAddresses
                }
            }
        }
    }
    $ErrorActionPreference = 'continue'
}
