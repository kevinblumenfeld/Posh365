function Select-SamAccountNameOrder {
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

    [array]$SamAccountNameOrder = "First Name then Last Name (example: JSmith)", "Last Name then First Name (example: SmithJ)" | 
        Out-GridView -OutputMode Single -Title "The SamAccountName is represented by First Name and Last Name - In which order (Choose 1 and click OK)"

    if ($SamAccountNameOrder -eq "First Name then Last Name (example: JSmith)") {
        "SamFirstFirst" | Out-File ($RootPath + "$($user).SamAccountNameOrder") -Force
    }
    else {
        "SamLastFirst" | Out-File ($RootPath + "$($user).SamAccountNameOrder") -Force
    }

}  