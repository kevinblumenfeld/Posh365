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
        $CanonicalName,
        [parameter()]
        [hashtable] $ADHashCN
    )
    Begin {
        import-module activedirectory -ErrorAction SilentlyContinue
    }
    Process {
        ForEach ($curDN in $CanonicalName) {
            $mailbox = $curDN
            (Get-Mailbox $curDN -erroraction silentlycontinue).GrantSendOnBehalfTo |
                where-object {$_ -ne $null}  | ForEach-Object {
                $User = $_
                try {
                    Get-ADGroupMember $_ -Recursive -ErrorAction stop | 
                        ForEach-Object {
                        New-Object -TypeName psobject -property @{
                            Mailbox    = $ADHashCN.$mailbox.DisplayName
                            UPN        = $ADHashCN.$mailbox.UPN
                            Granted    = $ADHashCN[$_.distinguishedname].DisplayName
                            GrantedUPN = $ADHashCN[$_.distinguishedname].UPN
                            Permission = "SendOnBehalf"
                        }
                    }
                } 
                Catch {
                    New-Object -TypeName psobject -property @{
                        Mailbox    = $ADHashCN.$mailbox.DisplayName
                        UPN        = $ADHashCN.$mailbox.UPN
                        Granted    = $ADHashCN."$User".DisplayName
                        GrantedUPN = $ADHashCN."$User".UPN
                        Permission = "SendOnBehalf"
                    }  
                }
            }
        }
    }
    END {
        
    }
}
