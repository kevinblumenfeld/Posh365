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
        foreach ($DN in $DistinguishedName) {
            $ADHashDN[$DN.DistinguishedName] = @{
                DisplayName        = $DN.DisplayName
                UserPrincipalName  = $DN.UserPrincipalName
                Logon              = $DN.logon
                PrimarySMTPAddress = $DN.PrimarySMTPAddress
            }
        }
    }
    End {
        $ADHashDN
    }
}
