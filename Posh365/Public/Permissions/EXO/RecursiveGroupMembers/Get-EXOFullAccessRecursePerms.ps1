function Get-EXOFullAccessRecursePerms {
    <#
    .SYNOPSIS
    Outputs Full Access permissions for each mailbox that has permissions assigned.
    This is for On-Premises Exchange 2010, 2013, 2016+
    
    .EXAMPLE
    
    (Get-Mailbox -ResultSize unlimited | Select -expandproperty distinguishedname) | Get-EXOFullAccessRecursePerms | Export-csv .\FA.csv -NoTypeInformation

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
        Get-MailboxPermission $_ |
            Where-Object {
            $_.AccessRights -like "*FullAccess*" -and 
            !$_.IsInherited -and !$_.user.tostring().startswith('S-1-5-21-') -and 
            !$_.user.tostring().startswith('NT AUTHORITY\SELF')
        } | ForEach-Object {
            $Identity = $_.Identity
            if ($GroupMemberHash.ContainsKey($_.User) -and $GroupMemberHash[$_.User]) {
                $GroupMemberHash[$_.User] | ForEach-Object {
                    [void]$listGroupMembers.Add($_)
                }
            }
            elseif (!($GroupMemberHash.ContainsKey($_.User))) {
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
        if ($listGroupMembers.Count -gt 0) {
            foreach ($CurlistGroupMember in $listGroupMembers) {
                [pscustomobject]@{
                    Mailbox              = $Identity
                    MailboxPrimarySMTP   = $RecipientHash[$Identity].PrimarySMTPAddress
                    Granted              = $RecipientDNHash[$CurlistGroupMember].Name
                    GrantedPrimarySMTP   = $RecipientDNHash[$CurlistGroupMember].PrimarySMTPAddress
                    RecipientTypeDetails = $Type          
                    Permission           = "FullAccess"
                }  
            }
        }
    }
    END {
        
    }
}
