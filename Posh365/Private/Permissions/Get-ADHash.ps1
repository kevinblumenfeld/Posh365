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
            $ADHash[$CurDN.logon] = @{
                DisplayName        = $CurDN.DisplayName
                UPN                = $CurDN.UserPrincipalName
                PrimarySMTPAddress = $CurDN.PrimarySMTPAddress
            }
        }
    }
    End {
        $ADHash
    }
}