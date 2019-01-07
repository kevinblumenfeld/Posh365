function Write-HostProgress {
    param (

        [Parameter()]
        [String]$Message,

        [Parameter()]
        [ValidateSet("Success", "Failed", "Neutral", "Information")]
        [String]$Status = "Information",

        [Parameter()]
        [int] $Total,

        [Parameter()]
        [int] $Count

    )
    $_ESC = "$([char]27)"
    $_FG = "$_ESC[38;5"
    $_BG = "$_ESC[48;5"
    $_Yellow = "$([char]27)[38;5;11m"
    $_Cyan = "$([char]27)[1;49;96m"
    $_White = "$([char]27)[38;5;3m"
    $_Red = "$([char]27)[91m"
    $_Green = "$([char]27)[38;5;2m"

    switch ($Status) {
        "Success" { $Color = $_Green }
        "Failed" { $Color = $_Red }
        "Neutral" { $Color = $_Cyan }
        Default { $Color = $_White }
    }
    $Pct = [int](($Count / $Total) * 100)
    $TimeStamp = "${_Yellow}[${_White}{0}%${_Yellow}]${_Yellow}[${_White}{1}${_Yellow}]${_Yellow}[${Color}{2}${_Yellow}]: ${Color}{3}" -f $Pct, (Get-Date).ToString("HH:mm:ss"), $Status, $Message
    Write-host $TimeStamp
}
