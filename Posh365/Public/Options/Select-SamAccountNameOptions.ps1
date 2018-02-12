function Select-SamAccountNameOptions {
    param ()
    $RootPath = $env:USERPROFILE + "\ps\"
    $User = $env:USERNAME
    Remove-Item -path ($RootPath + "$($user).SamAccountNameCharacters") -force -ErrorAction SilentlyContinue
    Remove-Item -path ($RootPath + "$($user).SamAccountNameOrder") -force -ErrorAction SilentlyContinue
    Remove-Item -path ($RootPath + "$($user).SamAccountNameNumberOfFirstNameCharacters") -force -ErrorAction SilentlyContinue
    Remove-Item -path ($RootPath + "$($user).SamAccountNameNumberOfLastNameCharacters") -force -ErrorAction SilentlyContinue

    While (!(Get-Content ($RootPath + "$($user).SamAccountNameCharacters") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
        Select-SamAccountNameCharacters
    }
    [int]$SamAccountNameCharacters = Get-Content ($RootPath + "$($user).SamAccountNameCharacters")     

    While (!(Get-Content ($RootPath + "$($user).SamAccountNameOrder") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
        Select-SamAccountNameOrder
    }
    $SamAccountNameOrder = Get-Content ($RootPath + "$($user).SamAccountNameOrder")
    
    if ($SamAccountNameOrder -eq "SamFirstFirst") {

        While (!(Get-Content ($RootPath + "$($user).SamAccountNameNumberOfFirstNameCharacters") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
            Select-SamAccountNameNumberOfFirstNameCharacters -SamAccountNameCharacters $SamAccountNameCharacters
        }
        [int]$SamAccountNameNumberOfFirstNameCharacters = Get-Content ($RootPath + "$($user).SamAccountNameNumberOfFirstNameCharacters")
    }
    else {
        While (!(Get-Content ($RootPath + "$($user).SamAccountNameNumberOfLastNameCharacters") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
            Select-SamAccountNameNumberOfLastNameCharacters -SamAccountNameCharacters $SamAccountNameCharacters
        }
        [int]$SamAccountNameNumberOfLastNameCharacters = Get-Content ($RootPath + "$($user).SamAccountNameNumberOfLastNameCharacters")
    }
}