function Select-SamAccountNameNumberOfFirstNameCharacters {
    param (
        [Parameter()]
        [int]$SamAccountNameCharacters,
        [Parameter()]
        [int]$SamAccountNameNumberOfLastNameCharacters
    )
    
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

    if ($SamAccountNameNumberOfLastNameCharacters) {
        while ($SamAccountNameNumberOfFirstNameCharacters.length -ne 1 ) {
            [array]$SamAccountNameNumberOfFirstNameCharacters = 1..($SamAccountNameCharacters - $SamAccountNameNumberOfLastNameCharacters)  | % {$_ -join ","}  | 
                Out-GridView -PassThru -Title "Select the Maximum number of characters from the user's First Name that will make up the SamAccountName (Choose 1 and click OK)"
        }    
        $SamAccountNameNumberOfFirstNameCharacters | Out-File ($RootPath + "$($user).SamAccountNameNumberOfFirstNameCharacters") -Force
    }
    else {
        while ($SamAccountNameNumberOfFirstNameCharacters.length -ne 1 ) {
            [array]$SamAccountNameNumberOfFirstNameCharacters = 1..($SamAccountNameCharacters)  | % {$_ -join ","}  | 
                Out-GridView -PassThru -Title "Select the Maximum number of characters from the user's First Name that will make up the SamAccountName (Choose 1 and click OK)"
        }    
        $SamAccountNameNumberOfFirstNameCharacters | Out-File ($RootPath + "$($user).SamAccountNameNumberOfFirstNameCharacters") -Force
    }
    
}
    