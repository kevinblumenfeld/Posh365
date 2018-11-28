function Import-365MsolUser { 
    <#
    .SYNOPSIS
    Add New MsolUsers to Office 365
    #>
    [CmdletBinding()]
    param (
        
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [psobject] $MsolUser

    )
    Begin {

    }
    Process {
        ForEach ($CurMsolUser in $MsolUser) {
            $Splat = @{
                DisplayName       = $CurMsolUser.DisplayName
                FirstName         = $CurMsolUser.FirstName
                LastName          = $CurMsolUser.LastName
                UserPrincipalName = $CurMsolUser.UserPrincipalName
                UsageLocation     = $CurMsolUser.UsageLocation
                LicenseAssignment = $CurMsolUser.AccountSkuId
                Password          = $CurMsolUser.Password
            }
            New-MsolUser @Splat
        }
    }
    End {

    }
}