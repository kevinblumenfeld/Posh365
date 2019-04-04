function Convert-OktaRateLimitToSleep {
    Param (

        [Parameter()]
        [long] $UnixTime,

        [Parameter()]
        $ApiTime

    )

    $Offset = New-TimeSpan -Start $ApiTime -End (Get-Date)
    $CorrectedTime = (Get-Date).AddSeconds( - $Offset.TotalSeconds)
    $WhenToRequest = [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($UnixTime))
    $SleepTime = ((New-TimeSpan -Start $CorrectedTime -End $WhenToRequest).Seconds + 2)

    $SleepTime
}