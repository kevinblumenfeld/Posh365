function Get-EXOFullAccessPerms {
    <#
    .SYNOPSIS
    Outputs Full Access permissions for each mailbox that has permissions assigned.
    This is for On-Premises Exchange 2010, 2013, 2016+
    
    .EXAMPLE
    
    (Get-Mailbox -ResultSize unlimited | Select -expandproperty distinguishedname) | Get-EXOFullAccessPerms | Export-csv .\FA.csv -NoTypeInformation

    If not running from Exchange Management Shell (EMS), run this first:

    Connect-Exchange -NoPrefix
    
    #>
    [CmdletBinding()]
    Param (
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        $DistinguishedName,
        [parameter()]
        [hashtable] $DGHash,
        [parameter()]
        [hashtable] $ADHash
    )
    Begin {
        
        

    }
    Process {
        ForEach ($curDN in $DistinguishedName) {
            $mailbox = $curDN
            Get-MailboxPermission $curDN |
                Where-Object {
                $_.AccessRights -like "*FullAccess*" -and 
                !$_.IsInherited -and !$_.user.tostring().startswith('S-1-5-21-') -and 
                !$_.user.tostring().startswith('NT AUTHORITY\SELF')
            } | ForEach-Object {
                $User = $_.User
                if ($DGHash.containskey($_.User)) {
                    $DGHash[$_.User].value | ForEach-Object {
                        New-Object -TypeName psobject -property @{
                            Mailbox     = $mailbox.Name
                            PrimarySMTP = $mailbox.primarysmtpaddress
                            Granted     = $ADHashDN[$_.distinguishedname].DisplayName
                            GrantedUPN  = $ADHashDN[$_.distinguishedname].UPN
                            Permission  = "FullAccess"
                        }  
                    }
                }
                else {
                    New-Object -TypeName psobject -property @{
                        Mailbox    = $ADHashDN.$mailbox.DisplayName
                        UPN        = $ADHashDN.$mailbox.UPN
                        Granted    = $ADHash[$User].DisplayName
                        GrantedUPN = $ADHash.$User.UPN
                        Permission = "FullAccess"
                    }  
                }
            }
        }
    }
    END {
        
    }
}
