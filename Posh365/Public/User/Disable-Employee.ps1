Function Disable-Employee {
    <#
    .SYNOPSIS
    Resets AD password to a random complex password, disables the AD User & Removes any Office 365 licenses.  Also converts mailbox to a Shared Mailbox.
    Lastly,allows for full access permissions to be granted to one more users over the shared mailbox.


    .EXAMPLE
    Disable-Employee -UserToDisable rtodd@contoso.com -UsersToGiveFullAccess @("fred.smith@contoso.com","sal.jones@contoso.com")
   
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
    Param (
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
        [string] $UserToDisable,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
        [string[]] $UsersToGiveFullAccess
    )
    
    Begin {

        $RootPath = $env:USERPROFILE + "\ps\"
        $User = $env:USERNAME
    
        While (!(Get-Content ($RootPath + "$($user).DomainController") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
            Select-DomainController
        }
        $DomainController = Get-Content ($RootPath + "$($user).DomainController")   
    }
    Process {
        
        $NewP = New-Password
        
        # Convert Cloud Mailbox to type, Shared.
        Convert-ToShared -UserToConvert $UserToDisable

        # Hide from Address List
        if ($UserToDisable -like "*@*") {
            Get-ADUser -LDAPFilter "(Userprincipalname=$UserToDisable)" -Server $domainController | 
                Set-ADUser -replace @{
                msExchHideFromAddressLists = $True
            }
            Get-ADUser -LDAPFilter "(Userprincipalname=$UserToDisable)" -Server $domainController |
                Set-ADAccountPassword -NewPassword (ConvertTo-SecureString -AsPlainText $NewP -Force)
        }
        else {
            Get-ADUser -LDAPFilter "(samaccountname=$UserToDisable)" -erroraction stop -Server $domainController | 
                Set-ADUser -replace @{
                msExchHideFromAddressLists = $True
            }
            Get-ADUser -LDAPFilter "(samaccountname=$UserToDisable)" -Server $domainController |
            Set-ADAccountPassword -NewPassword (ConvertTo-SecureString -AsPlainText $NewP -Force)
        }
        $UsersToGiveFullAccess | Grant-FullAccessToMailbox -Mailbox $UserToDisable
    }
    
    End {
    
    }
}