function Select-SamAccountNameCharacters {
    param ()
    $RootPath = $env:USERPROFILE + "\ps\"
    $User = $env:USERNAME

    if (!(Test-Path $RootPath)) {
        try {
            New-Item -ItemType Directory -Path $RootPath -ErrorAction STOP | Out-Null
        }
        catch {
            throw $_.Exception.Message
        }           
    }
    [array]$SamAccountNameCharacters = "1", "2", "3", "4", "5", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20" | 
        Out-GridView -OutputMode Single -Title "Select the Maximum number of characters in your SamAccountName (Choose 1 and click OK)"
    $SamAccountNameCharacters | Out-File ($RootPath + "$($user).SamAccountNameCharacters") -Force
}
    