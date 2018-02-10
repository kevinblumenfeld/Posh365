Function Get-ADHashCN {
    <#
    .SYNOPSIS

    .EXAMPLE
    
    #>
    param (
        [parameter(ValueFromPipeline = $true)]
        $CanonicalName
    )
    Begin {
        $ADHashCN = @{}
    }
    Process {
        foreach ($CurCN in $CanonicalName) {
            $ADHashCN[$CurCN.CanonicalName] = @{
                DisplayName = $CurCN.DisplayName
                UPN         = $CurCN.UserPrincipalName
                Logon       = $CurCN.logon
            }
        }

    }
    End {
        $ADHashCN
    }
     
}