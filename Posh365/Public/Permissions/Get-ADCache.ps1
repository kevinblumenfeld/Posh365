Function Get-ADCache {
        <#
    .SYNOPSIS
     Caches AD attributes.
     In two different hashtables, keys are:
     1. UserLogon (e.g. domain\SamAccountName)
     2. DistinguishedName
     
     This is for On-Premises Active Directory.

    .EXAMPLE

    Get-ADCache
    
    There will be no output only 2 Hashtables created.
    
    #>
    $Script:ADHash = @{}
    $Script:ADHashDN = @{}
    Get-ADUser -filter 'proxyaddresses -ne "$null"' -server ($dc + ":3268") -SearchBase (Get-ADRootDSE).rootdomainnamingcontext -SearchScope Subtree -Properties displayname, canonicalname | 
        Select distinguishedname, displayname, userprincipalname, @{n = "logon"; e = {$_.canonicalname.split('.')[0] + "\" + $_.samaccountname}} | % {
        $Script:ADHash[$_.logon] = @{
            DisplayName = $_.DisplayName
            UPN         = $_.UserPrincipalName
        }
        $Script:ADHashDN[$_.DistinguishedName] = @{
            DisplayName = $_.DisplayName
            UPN         = $_.UserPrincipalName
            Logon       = $_.logon
        }
    }
}