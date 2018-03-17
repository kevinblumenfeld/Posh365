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
        [parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        $DistinguishedName,

        [parameter()]
        [hashtable] $RecipientMailHash,

        [parameter()]
        [hashtable] $RecipientHash

    )
    Begin {
        

    }
    Process {
        Get-MailboxPermission $_ |
            Where-Object {
            $_.AccessRights -like "*FullAccess*" -and 
            !$_.IsInherited -and !$_.user.tostring().startswith('S-1-5-21-') -and 
            !$_.user.tostring().startswith('NT AUTHORITY\SELF')
        } | ForEach-Object {
            $User = $_.User
            if ($RecipientMailHash.ContainsKey($_.User)) {
                $User = $RecipientMailHash[$_.User].Name
                $Type = $RecipientMailHash[$_.User].RecipientTypeDetails
            }
            $Email = $_.User
            if ($RecipientHash.ContainsKey($_.User)) {
                $Email = $RecipientHash[$_.User].PrimarySMTPAddress
                $Type = $RecipientHash[$_.User].RecipientTypeDetails
            }
            [pscustomobject]@{
                Mailbox              = $_.Identity
                MailboxPrimarySMTP   = $RecipientHash[$_.Identity].PrimarySMTPAddress
                Granted              = $User
                GrantedPrimarySMTP   = $Email
                RecipientTypeDetails = $Type          
                Permission           = "FullAccess"
            }  
        }
    }
    END {
        
    }
}
