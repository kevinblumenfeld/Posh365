function Get-365MobileDevice {

    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('UPN')]
        $UserPrincipalName,

        [Parameter(ValueFromPipelineByPropertyName)]
        $DisplayName
    )
    begin {

    }
    process {
        foreach ($CurUpn in $UserPrincipalName) {
            if ($DisplayName -is [Array]) {
                $CurDisplayName = $DisplayName[$UserPrincipalName.IndexOf($CurUpn)]
            }
            else {
                $CurDisplayName = $DisplayName
            }

            $Mobile = Get-MobileDevice -Mailbox $CurUpn

            foreach ($CurMobile in $Mobile) {
                Write-Host "Getting info about mobile device(s) for $CurDisplayName"
                Start-Sleep -Seconds 2
                $Stat = Get-MobileDeviceStatistics -Identity "$($CurMobile.Guid)"
                [PSCustomObject]@{
                    DisplayName           = $CurDisplayName
                    UPN                   = $CurUpn
                    FriendlyName          = $CurMobile.FriendlyName
                    LastSuccessSync       = $Stat.LastSuccessSync
                    ClientType            = $CurMobile.ClientType
                    DeviceModel           = $CurMobile.DeviceModel
                    DeviceType            = $CurMobile.DeviceType
                    ClientVersion         = $CurMobile.ClientVersion
                    DeviceId              = $CurMobile.DeviceId
                    DeviceMobileOperator  = $CurMobile.DeviceMobileOperator
                    DeviceOS              = $CurMobile.DeviceOS
                    DeviceTelephoneNumber = $CurMobile.DeviceTelephoneNumber
                    Device                = $Stat.DeviceType
                    FirstSyncTime         = $CurMobile.FirstSyncTime
                    LastSyncAttemptTime   = $Stat.LastSyncAttemptTime
                    FoldersSynced         = $Stat.NumberOfFoldersSynced
                    Status                = $Stat.Status
                    IsRemoteWipeSupported = $Stat.IsRemoteWipeSupported
                    UserDisplayName       = $CurMobile.UserDisplayName
                }
            }
        }

    }
    end {

    }
}