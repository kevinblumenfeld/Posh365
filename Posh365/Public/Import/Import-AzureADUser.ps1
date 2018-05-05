function Import-AzureADUser { 
    <#
    .SYNOPSIS
    Add New Azure AD User to Office 365
    #>
    [CmdletBinding()]
    param (
        
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [psobject] $AzureADUser

    )    
    Begin {

    }
    Process {
        ForEach ($CurAzureADUser in $AzureADUser) {
            $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
            $PasswordProfile.Password = $CurAzureADUser.Password
            $Splat = @{
                AccountEnabled    = $True
                DisplayName       = $CurAzureADUser.DisplayName
                MailNickName      = $CurAzureADUser.Alias
                GivenName         = $CurAzureADUser.FirstName
                Surname           = $CurAzureADUser.LastName
                UserPrincipalName = $CurAzureADUser.UserPrincipalName
                UsageLocation     = $CurAzureADUser.UsageLocation
                PasswordProfile   = $PasswordProfile
            }
            New-AzureADUser @Splat
        }
    }
    End {

    }
}
