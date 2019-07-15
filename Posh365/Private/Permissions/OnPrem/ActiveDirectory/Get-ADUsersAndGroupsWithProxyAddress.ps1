Function Get-ADUsersAndGroupsWithProxyAddress {
    param (
        [Parameter()]
        [hashtable] $DomainNameHash
    )
    try {
        import-module activedirectory -ErrorAction Stop -Verbose:$false
    }
    catch {
        Write-Host "This module depends on the ActiveDirectory module."
        Write-Host "Please download and install from https://www.microsoft.com/en-us/download/details.aspx?id=45520"
        throw
    }

    # Find writable Global Catalog
    $context = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext('Forest')
    $dc = ([System.DirectoryServices.ActiveDirectory.GlobalCatalog]::FindOne($context, [System.DirectoryServices.ActiveDirectory.LocatorOptions]'ForceRediscovery, WriteableRequired')).name

    $Selectproperties = @(
        'DisplayName', 'UserPrincipalName', 'distinguishedname', 'SamAccountName', 'ProxyAddresses'
        'canonicalname', 'mail', 'Objectguid', 'msExchRecipientTypeDetails'
        'msExchRecipientDisplayType'
    )
    $CalculatedProps = @(
        @{n = "logon"; e = { ($DomainNameHash.($_.distinguishedname -replace '^.+?DC=' -replace ',DC=', '.')) + "\" + $_.samaccountname } },
        @{n = "PrimarySMTPAddress" ; e = { ( $_.proxyAddresses | Where-Object { $_ -cmatch "SMTP:*" }).Substring(5) } }
    )
    Get-ADUser -filter 'proxyaddresses -ne "$null"' -server ($dc + ":3268") -SearchBase (Get-ADRootDSE).rootdomainnamingcontext -SearchScope Subtree -Properties $SelectProperties |
    Select-Object ($Selectproperties + $CalculatedProps)
    Get-ADGroup -filter 'proxyaddresses -ne "$null"' -server ($dc + ":3268") -SearchBase (Get-ADRootDSE).rootdomainnamingcontext -SearchScope Subtree -Properties $SelectProperties |
    Select-Object ($Selectproperties + $CalculatedProps)
}
