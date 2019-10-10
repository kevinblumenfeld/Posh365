Function Get-ADGroupMemberHash {
    param (
        [Parameter()]
        [hashtable] $DomainNameHash,

        [Parameter()]
        [hashtable] $UserGroupHash
    )
    $context = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext('Forest')
    $dc = ([System.DirectoryServices.ActiveDirectory.GlobalCatalog]::FindOne($context, [System.DirectoryServices.ActiveDirectory.LocatorOptions]'ForceRediscovery, WriteableRequired')).name
    $GroupMemberHash = @{ }
    $GroupParams = @{
        Filter      = '*'
        Server      = ($dc + ':3268')
        SearchBase  = (Get-ADRootDSE).rootdomainnamingcontext
        SearchScope = 'Subtree'
    }
    Get-ADGroup @GroupParams | ForEach-Object {
        $GroupMemberHash.Add( ($DomainNameHash.($_.distinguishedname -replace '^.+?DC=' -replace ',DC=', '.')) + "\" + $_.samaccountname, @{
                SID     = $_.SID
                MEMBERS = @((@(Get-ADGroupMember -Identity $_.SID -Recursive) -ne '').foreach{ $UserGroupHash[$_.ObjectGuid] }) -ne '' -join '|'
            } )
    }
    $GroupMemberHash
}
