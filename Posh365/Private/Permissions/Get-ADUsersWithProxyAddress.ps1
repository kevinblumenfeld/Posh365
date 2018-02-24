Function Get-ADUsersWithProxyAddress {
    <#
    .SYNOPSIS


    .EXAMPLE

    
    #>
    param (
        [Parameter()]
        [hashtable] $DomainNameHash
    )
    Import-Module ActiveDirectory -ErrorAction SilentlyContinue
    
    Get-ADUser -filter 'proxyaddresses -ne "$null"' -server ($dc + ":3268") -SearchBase (Get-ADRootDSE).rootdomainnamingcontext -SearchScope Subtree -Properties displayname, canonicalname | Select distinguishedname, canonicalname, displayname, userprincipalname, @{n = "logon"; e = {($DomainNameHash.($_.distinguishedname -replace '^.+?DC=' -replace ',DC=', '.')) + "\" + $_.samaccountname}} 
}