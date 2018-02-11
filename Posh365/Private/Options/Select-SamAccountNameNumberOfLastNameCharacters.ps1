function Select-SamAccountNameNumberOfLastNameCharacters {
    param (  
        [Parameter()]
        [int]$SamAccountNameCharacters,
        [Parameter()]
        [int]$SamAccountNameNumberOfFirstNameCharacters 
    )
    
    $RootPath = $env:USERPROFILE + "\ps\"
    $User = $env:USERNAME
    $DisplayNameFormat = $null
    $SamAccountNameNumberOfLastNameCharacters = $null
    if (!(Test-Path $RootPath)) {
        try {
            New-Item -ItemType Directory -Path $RootPath -ErrorAction STOP | Out-Null
        }
        catch {
            throw $_.Exception.Message
        }           
    }
    if ($SamAccountNameNumberOfFirstNameCharacters) {
        write-host "IN FIRST SECTION (IN LAST)" $SamAccountNameNumberOfFirstNameCharacters
        write-host "IN FIRST SECTION (LENGTHTEST)" $SamAccountNameNumberOfLastNameCharacters.length
        while ($SamAccountNameNumberOfLastNameCharacters.length -ne 1 ) {
            write-host "IN LENGTH SECTION (IN LAST)" $SamAccountNameNumberOfLastNameCharacters.length
            [array]$SamAccountNameNumberOfLastNameCharacters = 1..($SamAccountNameCharacters - $SamAccountNameNumberOfFirstNameCharacters)  | % {$_ -join ","}  | 
                Out-GridView -PassThru -Title "Select the Maximum number of characters from the user's Last Name that will make up the SamAccountName (Choose 1 and click OK)"
        }    
        $SamAccountNameNumberOfLastNameCharacters | Out-File ($RootPath + "$($user).SamAccountNameNumberOfLastNameCharacters") -Force
    }
    else {
        write-host "IN FIRST-SECOND SECTION (IN LAST)" $SamAccountNameNumberOfFirstNameCharacters
        write-host "IN FIRST-SECOND SECTION (LENGTHTEST)" $SamAccountNameNumberOfLastNameCharacters.length
        while ($SamAccountNameNumberOfLastNameCharacters.length -ne 1 ) {
            [array]$SamAccountNameNumberOfLastNameCharacters = 1..($SamAccountNameCharacters)  | % {$_ -join ","}  | 
                Out-GridView -PassThru -Title "Select the Maximum number of characters from the user's Last Name that will make up the SamAccountName (Choose 1 and click OK)"
        }    
        $SamAccountNameNumberOfLastNameCharacters | Out-File ($RootPath + "$($user).SamAccountNameNumberOfLastNameCharacters") -Force
    }
    
}
    