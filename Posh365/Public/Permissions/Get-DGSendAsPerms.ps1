function Get-DGSendAsPerms {
    <#
    .SYNOPSIS
    Outputs Send As permissions for each mailbox that has permissions assigned.
    This is for On-Premises Exchange 2010, 2013, 2016+
    
    .EXAMPLE 
    
    (Get-Mailbox -ResultSize unlimited | Select -expandproperty distinguishedname) | Get-SendAsPerms | Export-csv .\SA.csv -NoTypeInformation

    If not running from Exchange Management Shell (EMS), run this first:

    Connect-Exchange -NoPrefix
    
    #>
    [CmdletBinding()]
    Param (
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        $DistinguishedName,

        [parameter()]
        [hashtable] $ADHashDGDN,
        
        [parameter()]
        [hashtable] $ADHashDG
    )
    Begin {
        Try {
            import-module activedirectory -ErrorAction Stop
        }
        Catch {
            Write-Host "This module depends on the ActiveDirectory module."
            Write-Host "Please download and install from https://www.microsoft.com/en-us/download/details.aspx?id=45520"
            throw
        }
    }
    Process {
        ForEach ($curDN in $DistinguishedName) {
            $DG = $curDN
            Get-ADPermission $curDN | Where-Object {
                $_.ExtendedRights -like "*Send-As*" -and 
                ($_.IsInherited -eq $false) -and 
                !($_.User -like "NT AUTHORITY\SELF") -and 
                !($_.User.tostring().startswith('S-1-5-21-'))
            } | ForEach-Object {
                $User = $_.User
                New-Object -TypeName PSObject -property @{
                    Object      = $ADHashDGDN.$DG.DisplayName
                    PrimarySMTP = $ADHashDGDN.$DG.PrimarySMTPAddress
                    Granted     = $ADHashDG."$User".DisplayName
                    GrantedUPN  = $ADHashDG."$User".UserPrincipalName
                    GrantedSMTP = $ADHashDG."$User".PrimarySMTPAddress
                    Permission  = "SendAs"  
                }
            } 
        }
    }
    END {
        
    }
}
