function Get-FullAccessPerms {
    <#
    .SYNOPSIS
    Outputs Full Access permissions for each object that has permissions assigned.
    This is for On-Premises Exchange 2010, 2013, 2016+
    
    .EXAMPLE
    
    (Get-Mailbox -ResultSize unlimited | Select -expandproperty distinguishedname) | Get-FullAccessPerms | Export-csv .\FA.csv -NoTypeInformation

    If not running from Exchange Management Shell (EMS), run this first:

    Connect-Exchange -NoPrefix
    
    #>
    [CmdletBinding()]
    Param (
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        $DistinguishedName,

        [parameter()]
        [hashtable] $ADHashDN,
        
        [parameter()]
        [hashtable] $ADHash
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
            $mailbox = $curDN
            Write-Verbose "Inspecting: `t $mailbox"
            Get-MailboxPermission $curDN |
                Where-Object {
                $_.AccessRights -like "*FullAccess*" -and 
                !$_.IsInherited -and !$_.user.tostring().startswith('S-1-5-21-') -and 
                !$_.user.tostring().startswith('NT AUTHORITY\SELF')
            } | ForEach-Object {
                $User = $_.User
                Write-Verbose "Has Full Access: `t $User"
                try {
                    Get-ADGroupMember ($_.user -split "\\")[1] -Recursive -ErrorAction stop | 
                        ForEach-Object {
                        New-Object -TypeName psobject -property @{
                            Object     = $ADHashDN["$mailbox"].DisplayName
                            UPN        = $ADHashDN["$mailbox"].UPN
                            Granted    = $ADHashDN["$_.distinguishedname"].DisplayName
                            GrantedUPN = $ADHashDN["$_.distinguishedname"].UPN
                            Permission = "FullAccess"
                        }  
                    }
                } 
                Catch {
                    New-Object -TypeName psobject -property @{
                        Object     = $ADHashDN["$mailbox"].DisplayName
                        UPN        = $ADHashDN["$mailbox"].UPN
                        Granted    = $ADHash["$User"].DisplayName
                        GrantedUPN = $ADHash["$User"].UPN
                        Permission = "FullAccess"
                    }  
                }
            }
        }
    }
    END {
        
    }
}
