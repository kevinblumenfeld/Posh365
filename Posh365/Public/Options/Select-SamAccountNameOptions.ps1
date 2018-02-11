function Select-SamAccountNameOptions {
    param ()
    $RootPath = $env:USERPROFILE + "\ps\"
    $User = $env:USERNAME
    Remove-Item -path ($RootPath + "$($user).SamAccountNameCharacters") -force -ErrorAction SilentlyContinue
    Remove-Item -path ($RootPath + "$($user).SamAccountNameOrder") -force -ErrorAction SilentlyContinue
    Remove-Item -path ($RootPath + "$($user).SamAccountNameNumberOfFirstNameCharacters") -force -ErrorAction SilentlyContinue
    Remove-Item -path ($RootPath + "$($user).SamAccountNameNumberOfLastNameCharacters") -force -ErrorAction SilentlyContinue

    # MAX NUMBER OF TOTAL CHARACTERS
    While (!(Get-Content ($RootPath + "$($user).SamAccountNameCharacters") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
        Select-SamAccountNameCharacters
    }
    [int]$SamAccountNameCharacters = Get-Content ($RootPath + "$($user).SamAccountNameCharacters") 
    
    # SAMAccountName ORDER
    While (!(Get-Content ($RootPath + "$($user).SamAccountNameOrder") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
        Select-SamAccountNameOrder
    }
    $SamAccountNameOrder = Get-Content ($RootPath + "$($user).SamAccountNameOrder")

    # IF FIRST FIRST
    if ($SamAccountNameOrder -eq "SamFirstFirst") {

        # Number of FirstName Characters
        While (!(Get-Content ($RootPath + "$($user).SamAccountNameNumberOfFirstNameCharacters") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
            Select-SamAccountNameNumberOfFirstNameCharacters -SamAccountNameCharacters $SamAccountNameCharacters
        }
        [int]$SamAccountNameNumberOfFirstNameCharacters = Get-Content ($RootPath + "$($user).SamAccountNameNumberOfFirstNameCharacters")
        
        # Number of LastName Characters
        While (!(Get-Content ($RootPath + "$($user).SamAccountNameNumberOfLastNameCharacters") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
            Select-SamAccountNameNumberOfLastNameCharacters -SamAccountNameCharacters $SamAccountNameCharacters -SamAccountNameNumberOfFirstNameCharacters $SamAccountNameNumberOfFirstNameCharacters
        }
        [int]$SamAccountNameNumberOfLastNameCharacters = Get-Content ($RootPath + "$($user).SamAccountNameNumberOfLastNameCharacters")
        
    }

    # IF LAST FIRST
    else {

        # Number of LastName Characters
        While (!(Get-Content ($RootPath + "$($user).SamAccountNameNumberOfLastNameCharacters") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
            Select-SamAccountNameNumberOfLastNameCharacters -SamAccountNameCharacters $SamAccountNameCharacters
        }
        [int]$SamAccountNameNumberOfLastNameCharacters = Get-Content ($RootPath + "$($user).SamAccountNameNumberOfLastNameCharacters")
        
        # Number of FirstName Characters
        While (!(Get-Content ($RootPath + "$($user).SamAccountNameNumberOfFirstNameCharacters") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
            Select-SamAccountNameNumberOfFirstNameCharacters -SamAccountNameCharacters $SamAccountNameCharacters -SamAccountNameNumberOfLastNameCharacters $SamAccountNameNumberOfLastNameCharacters
        }
        [int]$SamAccountNameNumberOfFirstNameCharacters = Get-Content ($RootPath + "$($user).SamAccountNameNumberOfFirstNameCharacters")
        
    }
}
    