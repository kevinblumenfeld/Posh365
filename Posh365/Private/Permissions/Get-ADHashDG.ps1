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
                PrimarySmtpAddress = $CurDN.PrimarySmtpAddress
            }
        }

    }
    End {
        $ADHashDG
    }

}