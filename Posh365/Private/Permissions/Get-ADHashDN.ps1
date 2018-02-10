Function Get-ADHashDN {
    <#
    .SYNOPSIS

    .EXAMPLE
    
    #>
    param (
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        $User
    )
    Begin {

    }
    Process {
        foreach ($CurUser in $User) {
            $ADHashDN[$CurUser.DistinguishedName] = @{
                DisplayName = $CurUser.DisplayName
                UPN         = $CurUser.UserPrincipalName
                Logon       = $CurUser.logon
            }
        }

    }
    End {

    }
     
}