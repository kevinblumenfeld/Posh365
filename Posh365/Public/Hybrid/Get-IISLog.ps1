function Get-IISLog {
    param (

        [Parameter()]
        $Server,

        [Parameter()]
        [string]
        $SearchString,

        [Parameter()]
        [switch]
        $BackEnd,

        [Parameter()]
        [int]
        $LogNumber = 1

    )
    if ($BackEnd) {
        $LastDigit = 2
    }
    else {
        $LastDigit = 1
    }
    if ($Server) {
        $LogPath = '\\{0}\C$\inetpub\logs\LogFiles\W3SVC{1}' -f $Server, $LastDigit
    }
    else {
        $LogPath = 'C:\inetpub\logs\LogFiles\W3SVC{0}' -f $LastDigit
    }
    $LogTemp = 'C:\Scripts\TempLog{0}.csv' -f [Guid]::NewGuid().toString().SubString(25)

    $RawLog = Get-Content (Get-ChildItem -Path $LogPath -File | Select-Object -skip ($LogNumber - 1) -First 1).fullname
    $TrimmedLog = $RawLog | Select-String -Pattern '#D.*|#F.*|#S.*|#V.*' -NotMatch

    $CleanLog = [system.collections.generic.list[string]]::new()

    if ($SearchString) {
        $TrimmedLog.foreach{ $CleanLog.Add(@($_) -like "*$SearchString*") }
    }
    else {
        $TrimmedLog.foreach{ $CleanLog.Add(@($_)) }
    }

    $LogHeader = ($RawLog | Select-Object -Skip 3 -First 1) -replace "#Fields: ", "" -replace "-", "" -replace "\(", "" -replace "\)", ""

    Set-Content -LiteralPath $LogTemp -Value ( [System.String]::Format("{0}{1}{2}", $LogHeader, [Environment]::NewLine, ( [System.String]::Join( [Environment]::NewLine, $CleanLog ) ) ) )
    $NewLog = Import-Csv -Path $LogTemp -Delimiter " "

    foreach ($New in $NewLog) {
        [PSCustomObject]@{
            date        = $New.date
            time        = $New.time
            sip         = $New.sip
            method      = $New.csmethod
            uri         = $New.csuristem
            port        = $New.sport
            username    = $New.csusername
            cip         = $New.cip
            userAgent   = $New.csuseragent
            referer     = $New.csReferer
            status      = $New.scStatus
            subStatus   = $New.scSubstatus
            win32Status = $New.scwin32Status
            timeTaken   = $New.timeTaken
            query       = $New.csUriQuery
        }
    }
    Remove-Item $LogTemp -Force
}
