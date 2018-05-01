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
        $ADHashDGDN = @{}
    }
    Process {
        foreach ($CurDN in $DistinguishedName) {
            $ADHashDGDN[$CurDN.DistinguishedName] = @{
                DisplayName        = $CurDN.DisplayName
                UPN                = $CurDN.UserPrincipalName
                PrimarySMTPAddress = $CurDN.PrimarySMTPAddress
                Logon              = $CurDN.logon
            }
        }
    }
    End {
        $ADHashDGDN
    }     
}