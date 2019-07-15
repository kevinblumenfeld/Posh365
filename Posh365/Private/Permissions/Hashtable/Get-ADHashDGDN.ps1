Function Get-ADHashDGDN {
    <#
    .SYNOPSIS

    .EXAMPLE

    #>
    param (
        [parameter(ValueFromPipeline = $true)]
        $DistinguishedName
    )
    Begin {
        $ADHashDGDN = @{ }
    }
    Process {
        foreach ($CurDN in $DistinguishedName) {
            $ADHashDGDN[$CurDN.DistinguishedName] = @{
                DisplayName        = $CurDN.DisplayName
                UserPrincipalName  = $CurDN.UserPrincipalName
                PrimarySmtpAddress = $CurDN.PrimarySmtpAddress
                Logon              = $CurDN.logon
            }
        }
    }
    End {
        $ADHashDGDN
    }
}
