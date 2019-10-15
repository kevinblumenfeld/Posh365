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
        LDAPFilter  = "(!(SamAccountName=Domain Computers))"
        Server      = ($dc + ':3268')
        SearchBase  = (Get-ADRootDSE).rootdomainnamingcontext
        SearchScope = 'Subtree'
        Properties  = 'CanonicalName'
    }
    Get-ADGroup @GroupParams | ForEach-Object {
        write-host "Caching Group Members: " -ForegroundColor Green -NoNewline
        write-host "$(($_.CanonicalName).Split('/')[0])" -ForegroundColor White -NoNewline
        write-host " - $($_.Name) " -ForegroundColor Green
        $GroupMemberHash.Add( ($DomainNameHash.($_.distinguishedname -replace '^.+?DC=' -replace ',DC=', '.')) + "\" + $_.samaccountname, @{
                SID     = $_.SID
                MEMBERS = @(Get-ADGroupMember -Identity $_.SID -Server ($_.CanonicalName).Split('/')[0] -Recursive) -ne '' | foreach-object { $_.ObjectGuid }
            } )
    }
    $GroupMemberHash
}
