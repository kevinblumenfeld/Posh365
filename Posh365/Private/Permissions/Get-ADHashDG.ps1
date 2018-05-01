Function Get-ADHashDG {
    <#
    .SYNOPSIS
    .EXAMPLE
    
    #>
    param (
        [parameter(ValueFromPipeline = $true)]
        $DistinguishedName
    )
    Begin {
        $ADHashDG = @{}
    }

    Process {
        foreach ($CurDN in $DistinguishedName) {
            $ADHashDG[$CurDN.logon] = @{
                DisplayName        = $CurDN.DisplayName
                UPN                = $CurDN.UserPrincipalName
                PrimarySMTPAddress = $CurDN.PrimarySMTPAddress
            }
        }

    }
    End {
        $ADHashDG
    }

}