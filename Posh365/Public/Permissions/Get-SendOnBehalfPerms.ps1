function Get-SendOnBehalfPerms {
    <#
    .SYNOPSIS
    Outputs SendOnBehalf permissions for each mailbox that has permissions assigned.
    This is for On-Premises Exchange 2010, 2013, 2016+
    
    .EXAMPLE 
    
	(Get-Mailbox -ResultSize unlimited | Select -expandproperty distinguishedname) | Get-SendOnBehalfPerms | Export-csv .\SOB.csv -NoTypeInformation

    If not running from Exchange Management Shell (EMS), run this first:

    Connect-Exchange -NoPrefix
    
    #>
    [CmdletBinding()]
    Param (
        [parameter(ValueFromPipeline = $true)]
        $DistinguishedName,
        
        [parameter()]
        [hashtable] $ADHashDN,

        [parameter()]
        [hashtable] $ADHashCN
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
            Write-Verbose "Inspecting: `t $Mailbox"
            (Get-Mailbox $curDN -erroraction silentlycontinue).GrantSendOnBehalfTo |
                where-object {$_ -ne $null}  | ForEach-Object {
                $CN = $_
                $DisplayName = $ADHashCN["$CN"].DisplayName
                Write-Verbose "Has Send On Behalf DN: `t $DisplayName"
                Write-Verbose "                   CN: `t $CN"
                try {
                    Get-ADGroupMember "$DisplayName" -Recursive -ErrorAction stop | 
                        ForEach-Object {
                        New-Object -TypeName psobject -property @{
                            Object             = $ADHashDN["$mailbox"].DisplayName
                            UPN                = $ADHashDN["$mailbox"].UPN
                            PrimarySMTPAddress = $ADHashDN["$mailbox"].PrimarySMTPAddress
                            Granted            = $ADHashDN["$($_.distinguishedname)"].DisplayName
                            GrantedUPN         = $ADHashDN["$($_.distinguishedname)"].UPN
                            GrantedSMTP        = $ADHashDN["$($_.distinguishedname)"].PrimarySMTPAddress
                            Checking           = $CN
                            GroupMember        = $($_.distinguishedname)
                            Type               = "GroupMember"
                            Permission         = "SendOnBehalf"
                        }
                    }
                } 
                Catch {
                    New-Object -TypeName psobject -property @{
                        Object             = $ADHashDN["$mailbox"].DisplayName
                        UPN                = $ADHashDN["$mailbox"].UPN
                        PrimarySMTPAddress = $ADHashDN["$mailbox"].PrimarySMTPAddress
                        Granted            = $ADHashCN["$CN"].DisplayName
                        GrantedUPN         = $ADHashCN["$CN"].UPN
                        GrantedSMTP        = $ADHashCN["$CN"].PrimarySMTPAddress
                        Checking           = $CN
                        GroupMember        = ""
                        Type               = "User"
                        Permission         = "SendOnBehalf"
                    }  
                }
            }
        }
    }
    END {
        
    }
}
