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
        [switch] $DontConvertToShared,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
        [string[]] $UsersToGiveFullAccess,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
        [string] $OUSearch2
    )
    
    Begin {

        $RootPath = $env:USERPROFILE + "\ps\"
        $User = $env:USERNAME
    
        While (!(Get-Content ($RootPath + "$($user).DomainController") -ErrorAction SilentlyContinue | Where-Object {$_.count -gt 0})) {
            Select-DomainController
        }
        $DomainController = Get-Content ($RootPath + "$($user).DomainController")  

        While (!(Get-Content ($RootPath + "$($user).TargetAddressSuffix") -ErrorAction SilentlyContinue | Where-Object {$_.count -gt 0})) {
            Select-TargetAddressSuffix
        }
        $targetAddressSuffix = Get-Content ($RootPath + "$($user).TargetAddressSuffix")

        try {
            Get-CloudAcceptedDomain -erroraction stop | Out-Null
        }
        catch {
            Connect-Cloud $targetAddressSuffix -EXOPrefix -ExchangeOnline
        }
        try {
            Get-AzureADTenantDetail -erroraction stop | Out-Null
        }
        catch {
            Connect-Cloud $targetAddressSuffix -AzureADver2
        }
    }
    Process {
        
        $NewP = New-Password
        
        # Hide from Address List, Set User's Password to Random Complex Password

        if ($UserToDisable -like "*@*") {
            Write-Output "Hiding mailbox from address lists"
            $PrimarySMTP = (Get-ADUser -LDAPFilter "(Userprincipalname=$UserToDisable)" -Properties Proxyaddresses -Server $domainController |
                    select @{n = "PrimarySMTPAddress" ; e = {( $_.proxyAddresses |
                                Where-Object {$_ -cmatch "SMTP:*"}).Substring(5)}
                }).PrimarySMTPAddress
            Get-ADUser -LDAPFilter "(Userprincipalname=$UserToDisable)" -Server $domainController | 
                Set-ADUser -replace @{
                msExchHideFromAddressLists = $True
            }  
            Write-Output "Resetting password to complex random password"
            Get-ADUser -LDAPFilter "(Userprincipalname=$UserToDisable)" -Server $domainController |
                Set-ADAccountPassword -NewPassword (ConvertTo-SecureString -AsPlainText $NewP -Force)
        }
        else {
            Write-Output "Hiding mailbox from address lists"  
            $PrimarySMTP = (Get-ADUser -LDAPFilter "(samaccountname=$UserToDisable)" -Properties Proxyaddresses -Server $domainController | 
                    select @{n = "PrimarySMTPAddress" ; e = {( $_.proxyAddresses |
                                Where-Object {$_ -cmatch "SMTP:*"}).Substring(5)}
                }).PrimarySMTPAddress
            Get-ADUser -LDAPFilter "(samaccountname=$UserToDisable)" -erroraction stop -Server $domainController | 
                Set-ADUser -replace @{
                msExchHideFromAddressLists = $True
            }
            Write-Output "Resetting password to complex random password"
            Get-ADUser -LDAPFilter "(samaccountname=$UserToDisable)" -Server $domainController |
                Set-ADAccountPassword -NewPassword (ConvertTo-SecureString -AsPlainText $NewP -Force)
        }

        # Remove ActiveSync and OWA for Mobile Devices
        Write-Output "Disabling ActiveSync and OWA for mobile devices"  
        Set-CloudCASMailbox $PrimarySMTP -ActiveSyncEnabled:$False -OWAforDevicesEnabled:$False

        # Revoke AzureAD
        Write-Output "Revoking Azure Token"  
        Revoke-AzureADUserAllRefreshToken -ObjectId $PrimarySMTP

        # Convert Cloud Mailbox to type, Shared.
        if (!$DontConvertToShared) {
            Write-Output "Converting to Shared Mailbox"  
            ConvertTo-Shared -UserToConvert $UserToDisable
        
            # Grant Full Access to mailbox if needed
            if ($UsersToGiveFullAccess) {
                Write-Output "Granting Full Access to Shared Mailbox" 
                $UsersToGiveFullAccess | Grant-FullAccessToMailbox -Mailbox $UserToDisable
            }
        }

        # Move disabled OUIf no conversion to a shared mailbox is needed
        if ($DontConvertToShared) {
            $OUSearch = "Disabled"
            $ou = (Get-ADOrganizationalUnit -Server $domainController -filter * -SearchBase (Get-ADDomain -Server $domainController).distinguishedname -Properties canonicalname | 
                    where {$_.canonicalname -match $OUSearch -or $_.canonicalname -match $OUSearch2
                } | Select canonicalname, distinguishedname| sort canonicalname | 
                    Out-GridView -OutputMode Single -Title "Choose the OU in which to Move the Disabled User, then click OK").distinguishedname 
            Write-Output "Disabling AD User and moving user to chosen OU"                 
            if ($UserToDisable -like "*@*") {
                Get-ADUser -LDAPFilter "(Userprincipalname=$UserToDisable)" -Server $domainController | % {
                    Move-ADObject $_.distinguishedname -TargetPath $ou
                }
                Get-ADUser -LDAPFilter "(Userprincipalname=$UserToDisable)" -Server $domainController | 
                    Set-ADUser -Enabled:$False
            }
            else {
                Get-ADUser -LDAPFilter "(samaccountname=$UserToDisable)" -Server $domainController | % {
                    Move-ADObject $_.distinguishedname -TargetPath $ou
                }  
                Get-ADUser -LDAPFilter "(samaccountname=$UserToDisable)" -Server $domainController | 
                    Set-ADUser -Enabled:$False         
            }
        }
    }
    
    End {
    
    }
}