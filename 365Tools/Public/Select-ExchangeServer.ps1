function Select-ExchangeServer {
    param ()
    $RootPath = $env:USERPROFILE + "\ps\"
    $User = $env:USERNAME
    $dn = $null
    $Ex = $null
    $EXCHServer = $null

    if (!(Test-Path $RootPath)) {
        try {
            New-Item -ItemType Directory -Path $RootPath -ErrorAction STOP | Out-Null
        }
        catch {
            throw $_.Exception.Message
        }           
    }
    $dn = "DC=$(($env:USERDNSDOMAIN).replace('.',',DC='))"
    $Ex = [adsi]"LDAP://CN=Exchange Install Domain Servers,CN=Microsoft Exchange System Objects,$($dn)" |
        Select -ExpandProperty member
    while (! $EXCHServer) {
        $EXCHServer = ([regex]::Matches($Ex, '(?<=CN=).*?(?=\,)').groups.value) | 
            Out-GridView -PassThru -Title "SELECT AN EXCHANGE SERVER AND CLICK OK"
    }
    $EXCHServer |  Out-File ($RootPath + "$($user).EXCHServer") -Force
}
    