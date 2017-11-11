function Select-DisplayNameFormat {
    param ()
    $RootPath = $env:USERPROFILE + "\ps\"
    $User = $env:USERNAME
    $DisplayNameFormat = $null

    if (!(Test-Path $RootPath)) {
        try {
            New-Item -ItemType Directory -Path $RootPath -ErrorAction STOP | Out-Null
        }
        catch {
            throw $_.Exception.Message
        }           
    }

    while (!$DisplayNameFormat) {
        $DisplayNameFormat = "FirstName LastName", "LastName, FirstName" | Out-GridView -PassThru -Title "SELECT `"DISPLAY NAME`" FORMAT"
    }
    if ($DisplayNameFormat -eq "FirstName LastName") {
        '"$FirstName" "$LastName"' |  Out-File ($RootPath + "$($user).DisplayNameFormat") -Force
    }
    if ($DisplayNameFormat -eq "LastName, FirstName") {
        '"$LastName" + ", " + "$FirstName"' |  Out-File ($RootPath + "$($user).DisplayNameFormat") -Force
    }
    
}
    