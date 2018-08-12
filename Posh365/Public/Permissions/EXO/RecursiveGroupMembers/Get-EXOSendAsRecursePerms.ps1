function Get-EXOSendAsRecursePerms {
    <#
    .SYNOPSIS
    Outputs Send As permissions for each mailbox that has permissions assigned.
    This is for Office 365
    
    .EXAMPLE
    
    (Get-Mailbox -ResultSize unlimited | Select -expandproperty distinguishedname) | Get-EXOSendAsRecursePerms | Export-csv .\SA.csv -NoTypeInformation
    
    #>
    [CmdletBinding()]
    Param (
        [parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        $DistinguishedName,

        [parameter()]
        [hashtable] $RecipientMailHash,

        [parameter()]
        [hashtable] $RecipientHash,

        [parameter()]
        [hashtable] $RecipientDNHash,
        
        [parameter()]
        [hashtable] $GroupMemberHash
    )

    Begin {
        

    }
    Process {
        $listGroupMembers = [System.Collections.Generic.HashSet[string]]::new()
        Get-RecipientPermission $_ |
            Where-Object {
            $_.AccessRights -like "*SendAs*" -and 
            !$_.IsInherited -and !$_.identity.tostring().startswith('S-1-5-21-') -and 
            !$_.trustee.tostring().startswith('NT AUTHORITY\SELF') -and !$_.trustee.tostring().startswith('NULL SID')
        } | ForEach-Object {
            $Identity = $_.Identity
            $Trustee = $_.Trustee
            if ($GroupMemberHash.ContainsKey($Trustee) -and $GroupMemberHash[$Trustee]) {
                $GroupMemberHash[$Trustee] | ForEach-Object {
                    [void]$listGroupMembers.Add($_)
                }
            }
            elseif (!($GroupMemberHash.ContainsKey($Trustee))) {
                if ($RecipientMailHash.ContainsKey($Trustee)) {
                    $Trustee = $RecipientMailHash["$Trustee"].Name
                    $Type = $RecipientMailHash["$Trustee"].RecipientTypeDetails
                }
                $Email = $Trustee
                if ($RecipientHash.ContainsKey($Trustee)) {
                    $Email = $RecipientHash["$Trustee"].PrimarySMTPAddress
                    $Type = $RecipientHash["$Trustee"].RecipientTypeDetails
                }
                [pscustomobject]@{
                    Mailbox              = $_.Identity
                    MailboxPrimarySMTP   = $RecipientHash["$_.Identity"].PrimarySMTPAddress
                    Granted              = $Trustee
                    GrantedPrimarySMTP   = $Email
                    RecipientTypeDetails = $Type          
                    Permission           = "SendAs"
                }  
            }
        }
        if ($listGroupMembers.Count -gt 0) {
            foreach ($CurlistGroupMember in $listGroupMembers) {
                [pscustomobject]@{
                    Mailbox              = $Identity
                    MailboxPrimarySMTP   = $RecipientHash["$Identity"].PrimarySMTPAddress
                    Granted              = $RecipientDNHash["$CurlistGroupMember"].Name
                    GrantedPrimarySMTP   = $RecipientDNHash["$CurlistGroupMember"].PrimarySMTPAddress
                    RecipientTypeDetails = $Type          
                    Permission           = "SendAs"
                }  
            }
        }
    }
    END {
        
    }
}
