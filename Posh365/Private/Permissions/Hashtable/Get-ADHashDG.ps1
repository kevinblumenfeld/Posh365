Function Get-ADHashDG {
    <#
    .SYNOPSIS
    .EXAMPLE

    #>
    param (
        [parameter(ValueFromPipeline = $true)]
        $DistinguishedName
    )
    begin {
        $ADHashDG = @{ }
    }
    process {
        foreach ($CurDN in $DistinguishedName) {
            $ADHashDG[$CurDN.logon] = @{
                DisplayName        = $CurDN.DisplayName
                UserPrincipalName  = $CurDN.UserPrincipalName
                PrimarySMTPAddress = $CurDN.PrimarySMTPAddress
            }
        }
    }
    end {
        $ADHashDG
    }
}
