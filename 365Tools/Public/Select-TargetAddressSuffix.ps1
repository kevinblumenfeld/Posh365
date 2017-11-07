function Select-TargetAddressSuffix {
    param ()
    $RootPath = $env:USERPROFILE + "\ps\"
    $User = $env:USERNAME
    $DomainFQDN = $null
    $RootDSE = $null
    $ConfigNC = $null
    $ADObjectSplat = $null
    $TargetAddressSuffix = $null
    

    if (!(Test-Path $RootPath)) {
        try {
            New-Item -ItemType Directory -Path $RootPath -ErrorAction STOP | Out-Null
        }
        catch {
            throw $_.Exception.Message
        }           
    }
    $DomainFQDN = ([System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()).name
    $RootDSE = [ADSI]"LDAP://$DomainFqdn/RootDSE"
    $ConfigNC = $RootDSE.configurationNamingContext.ToString()

    $ADObjectSplat = @{
        LDAPFilter = "(&(objectClass=msExchAcceptedDomain))"
        SearchBase = $ConfigNC
        Server     = $DomainFqdn
        Properties = "msExchAcceptedDomainName"
    }
    while (! $TargetAddressSuffix) {
        $TargetAddressSuffix = Get-ADObject @ADObjectSplat | Select-Object -ExpandProperty msExchAcceptedDomainName| ? {$_ -like "*.mail.onmicrosoft.com"} | 
            Out-GridView -Passthru -Title "SELECT THE TARGET ADDRESS SUFFIX"
    }
    $TargetAddressSuffix | Out-File ($RootPath + "$($user).TargetAddressSuffix") -Force 
}