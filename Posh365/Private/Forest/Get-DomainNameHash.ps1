Function Get-DomainNameHash {
    <#
    .SYNOPSIS

    .EXAMPLE
    
    #>
    param (

    )
    Begin {
        $DomainNameHash = @{}
    }
    Process {
        $Domains = ([System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().domains) | Select -expand name
        foreach ($Domain in $Domains) {
            $DomainNameHash[$Domain] = (ConvertTo-NetBios -domain $Domain)
        }
    }
    End {
        $DomainNameHash
    }     
}