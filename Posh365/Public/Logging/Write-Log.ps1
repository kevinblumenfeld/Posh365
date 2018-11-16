Function Write-Log {
    param
    (

        [Parameter()]
        [string] $Log,

        [Parameter()]
        [string] $AddToLog

    )

    Add-Content -Path $Log -Value $AddToLog
}