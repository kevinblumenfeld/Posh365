function Get-SendAsPerms {
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
        [hashtable] $ADHashDN,
        
        [parameter()]
        [hashtable] $ADHash
    )
    Begin {
        Try {
            import-module activedirectory -ErrorAction Stop -Verbose:$false
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
            Get-ADPermission $curDN | Where-Object {
                $_.ExtendedRights -like "*Send-As*" -and 
                ($_.IsInherited -eq $false) -and 
                !($_.User -like "NT AUTHORITY\SELF") -and 
                !($_.User.tostring().startswith('S-1-5-21-'))
            } | ForEach-Object {
                $User = $_.User
                Write-Verbose "Has Send As: `t $User"
                try {
                    Get-ADGroupMember ($_.user -split "\\")[1] -Recursive -ErrorAction stop | 
                        ForEach-Object {
                        New-Object -TypeName psobject -property @{
                            Object             = $ADHashDN["$mailbox"].DisplayName
                            UPN                = $ADHashDN["$mailbox"].UPN
                            PrimarySMTPAddress = $ADHashDN["$mailbox"].PrimarySMTPAddress
                            Granted            = $ADHashDN["$($_.distinguishedname)"].DisplayName
                            GrantedUPN         = $ADHashDN["$($_.distinguishedname)"].UPN
                            GrantedSMTP        = $ADHashDN["$($_.distinguishedname)"].PrimarySMTPAddress
                            Permission         = "SendAs"
                        }    
                    }
                } 
                Catch {
                    New-Object -TypeName psobject -property @{
                        Object             = $ADHashDN["$mailbox"].DisplayName
                        UPN                = $ADHashDN["$mailbox"].UPN
                        PrimarySMTPAddress = $ADHashDN["$mailbox"].PrimarySMTPAddress
                        Granted            = $ADHash["$User"].DisplayName
                        GrantedUPN         = $ADHash["$User"].UPN
                        GrantedSMTP        = $ADHash["$User"].PrimarySMTPAddress
                        Permission         = "SendAs"
                    }
                }
            }
        }
    }
    END {
        
    }
}
