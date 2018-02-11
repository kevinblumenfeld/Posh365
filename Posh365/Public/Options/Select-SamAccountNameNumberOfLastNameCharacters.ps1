function Select-SamAccountNameNumberOfLastNameCharacters {
    param (
        [Parameter()]
        [int]$SamAccountNameNumberOfFirstNameCharacters,
    
        [Parameter()]
        [int]$SamAccountNameCharacters
            
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

    while ($SamAccountNameNumberOfLastNameCharacters.length -ne 1 ) {
        [array]$SamAccountNameNumberOfLastNameCharacters = 1..($SamAccountNameCharacters - $SamAccountNameNumberOfFirstNameCharacters)  | % {$_ -join ","}  | 
            Out-GridView -PassThru -Title "Select the Maximum number of characters from the user's Last Name that will make up the SamAccountName (Choose 1 and click OK)"
    }    
    $SamAccountNameNumberOfLastNameCharacters | Out-File ($RootPath + "$($user).SamAccountNameNumberOfLastNameCharacters") -Force
}
    