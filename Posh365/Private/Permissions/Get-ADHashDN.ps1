Function Get-ADHashDN {
    <#
    .SYNOPSIS

    .EXAMPLE

    #>
    param (
        [parameter(ValueFromPipeline = $true)]
        $DistinguishedName
    )
    Begin {
        $ADHashDN = @{ }
    }
    Process {
        foreach ($CurDN in $DistinguishedName) {
            $ADHashDN[$CurDN.DistinguishedName] = @{
                DisplayName        = $CurDN.DisplayName
                UserPrincipalName  = $CurDN.UserPrincipalName
                Logon              = $CurDN.logon
                PrimarySMTPAddress = $CurDN.PrimarySMTPAddress
            }
        }
    }
    End {
        $ADHashDN
    }
}
