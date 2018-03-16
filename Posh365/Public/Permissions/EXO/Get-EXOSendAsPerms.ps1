function Get-EXOSendAsPerms {
    <#
    .SYNOPSIS
    Outputs Send As permissions for each mailbox that has permissions assigned.
    This is for Office 365
    
    .EXAMPLE
    
    (Get-Mailbox -ResultSize unlimited | Select -expandproperty distinguishedname) | Get-EXOSendAsPerms | Export-csv .\SA.csv -NoTypeInformation
    
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
        Get-RecipientPermission $_ |
            Where-Object {
            $_.AccessRights -like "*SendAs*" -and 
            !$_.IsInherited -and !$_.identity.tostring().startswith('S-1-5-21-') -and 
            !$_.trustee.tostring().startswith('NT AUTHORITY\SELF') -and !$_.trustee.tostring().startswith('NULL SID')
        } | ForEach-Object {
            $Trustee = $_.Trustee
            if ($RecipientMailHash.ContainsKey($_.Trustee)) {
                $Trustee = $RecipientMailHash[$_.Trustee].Name
                $Type = $RecipientMailHash[$_.Trustee].RecipientTypeDetails
            }
            $Email = $_.Trustee
            if ($RecipientHash.ContainsKey($_.Trustee)) {
                $Email = $RecipientHash[$_.Trustee].PrimarySMTPAddress
                $Type = $RecipientHash[$_.Trustee].RecipientTypeDetails
            }
            [pscustomobject]@{
                Mailbox              = $_.Identity
                MailboxPrimarySMTP   = $RecipientHash[$_.Identity].PrimarySMTPAddress
                Granted              = $Trustee
                GrantedPrimarySMTP   = $Email
                RecipientTypeDetails = $Type          
                Permission           = "SendAs"
            }  
        }
    }
    END {
        
    }
}
