function Get-EXOSendAsPerms {
    <#
    .SYNOPSIS
    Outputs Send As permissions for each object that has permissions assigned.
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
        [hashtable] $RecipientHash,

        [parameter()]
        [hashtable] $RecipientLiveIDHash

    )
    Begin {
        

    }
    Process {
        Write-Verbose "Inspecting: `t $_"
        Get-RecipientPermission $_ |
            Where-Object {
            $_.AccessRights -like "*SendAs*" -and 
            !$_.IsInherited -and !$_.identity.startswith('S-1-5-21-') -and 
            !$_.trustee.startswith('NT AUTHORITY\SELF') -and !$_.trustee.startswith('NULL SID') -and
            !$_.trustee.contains('\')
        } | ForEach-Object {
            $Trustee = $_.Trustee
            $Type = $null
            Write-Verbose "Granted Send As: `t $Trustee"
            if ($RecipientMailHash.ContainsKey($_.Trustee)) {
                $Trustee = $RecipientMailHash[$_.Trustee].Name
                $Email = $RecipientMailHash[$_.Trustee].PrimarySMTPAddress
                $Type = $RecipientMailHash[$_.Trustee].RecipientTypeDetails
            }
            $Email = $_.Trustee
            if ($RecipientHash.ContainsKey($_.Trustee)) {
                $Email = $RecipientHash[$_.Trustee].PrimarySMTPAddress
                $Type = $RecipientHash[$_.Trustee].RecipientTypeDetails
            }
            if ($RecipientLiveIDHash.ContainsKey($_.Trustee)) {
                $Trustee = $RecipientLiveIDHash[$_.Trustee].Name 
                $Email = $RecipientLiveIDHash[$_.Trustee].PrimarySMTPAddress
                $Type = $RecipientLiveIDHash[$_.Trustee].RecipientTypeDetails
            }
            [pscustomobject]@{
                Object               = $_.Identity
                ObjectPrimarySMTP    = $RecipientHash[$_.Identity].PrimarySMTPAddress
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
