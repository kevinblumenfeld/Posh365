Function Get-DomainNameHash {

    param (

    )
    end {
        $DomainNameHash = @{ }

        $DomainList = ([System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().domains) | Select -ExpandProperty Name
        foreach ($Domain in $DomainList) {
            $DomainNameHash[$Domain] = (ConvertTo-NetBios -domain $Domain)
        }
        $DomainNameHash
    }
}
