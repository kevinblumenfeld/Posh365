Function Disable-Employee {
    <#
    .SYNOPSIS
    Disables the AD User & Removes any licenses.  Also coverts mailbox to a Shared Mailbox when requested

    .EXAMPLE
    Disable-Employee -UserToDisable rtodd@contoso.com -UsersToGiveFullAccess @("fred.smith@contoso.com","sal.jones@contoso.com")
   
    #>
    [CmdletBinding()]
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
        # Convert Cloud Mailbox to type, Shared.

        Convert-ToShared -UserToConvert $UserToDisable

        # Hide from Address List
        if ($UserToDisable -like "*@*") {
            Get-ADUser -LDAPFilter "(Userprincipalname=$UserToDisable)" -Server $domainController | 
                Set-ADUser -replace @{
                msExchHideFromAddressLists = $True
            }
        }
        else {
            Get-ADUser -LDAPFilter "(samaccountname=$UserToDisable)" -erroraction stop -Server $domainController | 
                Set-ADUser -replace @{
                msExchHideFromAddressLists = $True
            }
        }
        $UsersToGiveFullAccess | Add-FullAccessToMailbox -Mailbox $UserToDisable
    }
    
    End {
    
    }
}