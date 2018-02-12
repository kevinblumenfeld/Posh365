function Select-SamAccountNameNumberOfLastNameCharacters {
    param (  
        [Parameter()]
        [int]$SamAccountNameCharacters,
        [Parameter()]
        [int]$SamAccountNameNumberOfFirstNameCharacters 
    )
    
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

    if ($SamAccountNameNumberOfFirstNameCharacters) {
        [array]$SamAccountNameNumberOfLastNameCharacters = 1..($SamAccountNameCharacters - $SamAccountNameNumberOfFirstNameCharacters)  | % {$_ -join ","}  | 
            Out-GridView -OutputMode Single -Title "Select the Maximum number of characters from the user's Last Name that will make up the SamAccountName (Choose 1 and click OK)"    
        $SamAccountNameNumberOfLastNameCharacters | Out-File ($RootPath + "$($user).SamAccountNameNumberOfLastNameCharacters") -Force
    }
    else {
        [array]$SamAccountNameNumberOfLastNameCharacters = 1..($SamAccountNameCharacters)  | % {$_ -join ","}  | 
            Out-GridView -OutputMode Single -Title "Select the Maximum number of characters from the user's Last Name that will make up the SamAccountName (Choose 1 and click OK)"  
        $SamAccountNameNumberOfLastNameCharacters | Out-File ($RootPath + "$($user).SamAccountNameNumberOfLastNameCharacters") -Force
    }
    
}
    