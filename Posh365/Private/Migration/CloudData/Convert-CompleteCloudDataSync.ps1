function Convert-CompleteCloudDataSync {
    [CmdletBinding()]
    param (
        [Parameter()]
        $ResultObject,

        [Parameter()]
        [switch]
        $Write
    )
    $ErrorActionPreference = 'stop'
    $Count = @($ResultObject).Count
    $iUP = 0
    $Time = [DateTime]::Now.ToString('yyyy-MM-dd-hhmm')
    foreach ($Result in $ResultObject) {
        $iUP++
        [PSCustomObject]@{
            Num                       = '[{0} of {1}]' -f $iUP, $Count
            Time                      = $Time
            LogTime                   = $Result.Time
            DisplayName               = $Result.DisplayName
            SourceType                = $Result.SourceType
            SourceUserPrincipalName   = $Result.SourceUserPrincipalName
            TargetId                  = $Result.TargetId
            SourceEmailAddresses      = $Result.SourceEmailAddresses
            SourcePrimarySmtpAddress  = $Result.SourcePrimarySmtpAddress
            UserPrincipalName         = $Result.UserPrincipalName
            Name                      = $Result.Name
            MicrosoftOnlineServicesID = $Result.MicrosoftOnlineServicesID
            PrimarySMTPAddress        = $Result.PrimarySMTPAddress
            Alias                     = $Result.Alias
            ExternalEmailAddress      = $Result.ExternalEmailAddress
            ExchangeGuid              = $Result.ExchangeGuid
            SourceId                  = $Result.SourceId
            TargetEmailAddresses      = $Result.TargetEmailAddresses
        }
    }
    $ErrorActionPreference = 'continue'
}
