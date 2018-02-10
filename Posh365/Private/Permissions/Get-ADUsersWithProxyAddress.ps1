Function Get-ADUsersWithProxyAddress {
    <#
    .SYNOPSIS


    .EXAMPLE

    
    #>
    param (

    )
    Import-Module ActiveDirectory -ErrorAction SilentlyContinue
    
    Get-ADUser -filter 'proxyaddresses -ne "$null"' -server ($dc + ":3268") -SearchBase (Get-ADRootDSE).rootdomainnamingcontext -SearchScope Subtree -Properties displayname, canonicalname | 
        Select distinguishedname, displayname, userprincipalname, @{n = "logon"; e = {$_.canonicalname.split('.')[0] + "\" + $_.samaccountname}} 
}