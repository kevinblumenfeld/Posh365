Function Get-ADHashDN {
    <#
    .SYNOPSIS

    .EXAMPLE
    
    #>
    param (
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        $DistinguishedName
    )
    Begin {
        $ADHashDN = @{}
    }
    Process {
        foreach ($CurDN in $DistinguishedName) {
            $ADHashDN[$CurDN.DistinguishedName] = @{
                DisplayName = $CurDN.DisplayName
                UPN         = $CurDN.UserPrincipalName
                Logon       = $CurDN.logon
            }
        }

    }
    End {

    }
     
}