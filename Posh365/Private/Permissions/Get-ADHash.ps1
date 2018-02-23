Function Get-ADHash {
    <#
    .SYNOPSIS

    .EXAMPLE
    
    #>
    param (
        [parameter(ValueFromPipeline = $true)]
        $DistinguishedName
    )
    Begin {
        $ADHash = @{}
    }

    Process {
        foreach ($CurDN in $DistinguishedName) {
            New-Object -TypeName psobject -property @{
                Logon       = $CurDN.Logon
                DisplayName = $CurDN.DisplayName
                UPN         = $CurDN.UserPrincipalName
            } | ForEach-Object {
                $ADhash.($_.logon) = $_ 
            }
        } 
    }
    End {
        $ADHash
    }
     
}