Function Get-ADObjectWithProxyAddress {
    <#
    .SYNOPSIS


    .EXAMPLE

    
    #>
    param (
        [Parameter()]
        [hashtable] $DomainNameHash
    )
    Try {
        import-module activedirectory -ErrorAction Stop
    }
    Catch {
        Write-Host "This module depends on the ActiveDirectory module."
        Write-Host "Please download and install from https://www.microsoft.com/en-us/download/details.aspx?id=45520"
        throw
    }

    # Find writable Global Catalog 
    $context = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext('Forest')
    $dc = ([System.DirectoryServices.ActiveDirectory.GlobalCatalog]::FindOne($context, [System.DirectoryServices.ActiveDirectory.LocatorOptions]'ForceRediscovery, WriteableRequired')).name
    
    $Selectproperties = @(
        'UserPrincipalName', 'distinguishedname', 'canonicalname', 'displayname'
    )
    $CalculatedProps = @(
        @{n = "logon"; e = {($DomainNameHash.($_.distinguishedname -replace '^.+?DC=' -replace ',DC=', '.')) + "\" + $_.samaccountname}},
        @{n = "PrimarySMTPAddress" ; e = {( $_.proxyAddresses | Where-Object {$_ -cmatch "SMTP:*"}).Substring(5)}}
    )
    Get-ADUser -filter 'proxyaddresses -ne "$null"' -server ($dc + ":3268") -SearchBase (Get-ADRootDSE).rootdomainnamingcontext -SearchScope Subtree -Properties displayname, canonicalname, proxyaddresses |
        Select-Object ($Selectproperties + $CalculatedProps)
    Get-ADGroup -filter 'proxyaddresses -ne "$null"' -server ($dc + ":3268") -SearchBase (Get-ADRootDSE).rootdomainnamingcontext -SearchScope Subtree -Properties displayname, canonicalname, proxyaddresses |
        Select-Object ($Selectproperties + $CalculatedProps)
} 