Function Get-ADHash {
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
            $ADHash[$CurUser.logon] = @{
                DisplayName = $CurUser.DisplayName
                UPN         = $CurUser.UserPrincipalName
            }
        }

    }
    End {

    }
     
}